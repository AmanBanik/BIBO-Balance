import os
import platform
import cffi
import numpy as np

class BiboEnv:
    """
    A Gymnasium-like wrapper for the high-performance C11 BIBO Balance simulator.
    Uses CFFI to completely bypass Python's GIL during physics steps.
    """
    def __init__(self, build_dir="../build"):
        self.ffi = cffi.FFI()
        
        # Exact matching of the C ABI we defined in cffi_interface.h
        self.ffi.cdef("""
            typedef struct BiboSimulator BiboSimulator;
            BiboSimulator* bibo_env_create();
            void bibo_env_destroy(BiboSimulator* env);
            void bibo_env_reset(BiboSimulator* env, float spawn_x, float spawn_y, float spawn_z);
            void bibo_env_step(BiboSimulator* env, float a0, float a1, float a2, float a3, float dt);
            void bibo_env_get_state(BiboSimulator* env, float* out_state);
            int bibo_env_is_stable(BiboSimulator* env);
            float bibo_env_get_energy(BiboSimulator* env);
            int bibo_env_get_step_count(BiboSimulator* env);
        """)
        
        # Resolve shared library path
        ext = ".dylib" if platform.system() == "Darwin" else ".so"
        lib_path = os.path.abspath(os.path.join(os.path.dirname(__file__), build_dir, f"libbibo_cffi{ext}"))
        
        if not os.path.exists(lib_path):
            raise FileNotFoundError(
                f"Could not find physics engine shared library at {lib_path}. "
                "Did you run 'cmake --build build'?"
            )
            
        # Load library and allocate the simulator instance strictly on the C heap
        self.lib = self.ffi.dlopen(lib_path)
        self._env_ptr = self.lib.bibo_env_create()
        if not self._env_ptr:
            raise RuntimeError("Failed to allocate C simulator memory.")
            
        self.dt = 0.01  # Fixed time step of 10ms for RL agent (100Hz physical control)
        
        # Pre-allocate C float array to prevent allocations during step()
        self._state_c_arr = self.ffi.new("float[21]")

    def __del__(self):
        # Prevent memory leaks by freeing the C struct when Python GC runs
        if hasattr(self, 'lib') and hasattr(self, '_env_ptr'):
            self.lib.bibo_env_destroy(self._env_ptr)

    def reset(self, spawn_pos=(0.0, 0.0, 0.22)):
        """
        Resets the simulator. Optionally accepts a custom 3D spawn position.
        Returns the initial observation array.
        """
        self.lib.bibo_env_reset(self._env_ptr, float(spawn_pos[0]), float(spawn_pos[1]), float(spawn_pos[2]))
        return self._get_obs()

    def step(self, action):
        """
        Takes a 4-element action array (Delta Lengths for the 4 actuators).
        Advances the simulator by self.dt and returns (obs, reward, terminated, truncated, info).
        """
        # Step the highly optimized C loop
        self.lib.bibo_env_step(
            self._env_ptr, 
            float(action[0]), 
            float(action[1]), 
            float(action[2]), 
            float(action[3]), 
            self.dt
        )
        
        obs = self._get_obs()
        
        # Extract C diagnostics
        is_stable = bool(self.lib.bibo_env_is_stable(self._env_ptr))
        energy = float(self.lib.bibo_env_get_energy(self._env_ptr))
        steps = int(self.lib.bibo_env_get_step_count(self._env_ptr))
        
        # Terminal condition: ball drops off platform bounds.
        # Platform is 0.6m long (x in [-0.3, 0.3]) and 0.2m wide (y in [-0.1, 0.1])
        ball_x, ball_y = obs[0], obs[1]
        terminated = bool(abs(ball_x) > 0.3 or abs(ball_y) > 0.1)
        
        # Base Reward logic (will be extended in RL phases)
        reward = 1.0  # Survive bonus
        if is_stable:
            reward += 10.0
        if terminated:
            reward = -100.0
            
        info = {
            "is_stable": is_stable,
            "energy": energy,
            "step_count": steps
        }
        
        return obs, reward, terminated, False, info

    def _get_obs(self):
        """Copies the state strictly via C pointers into a fast numpy array."""
        self.lib.bibo_env_get_state(self._env_ptr, self._state_c_arr)
        # Using np.frombuffer is slightly faster than list comprehension for FFI
        return np.frombuffer(self.ffi.buffer(self._state_c_arr), dtype=np.float32).copy()
