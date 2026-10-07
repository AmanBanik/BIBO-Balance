import os
import platform
import cffi
import numpy as np

class BiboBatchedEnv:
    """
    Batched GPU simulator for BIBO Balance.
    Uses zero-copy PyBuffer views over CUDA Pinned Memory.
    """
    def __init__(self, num_envs=100000, build_dir="../build"):
        self.num_envs = num_envs
        self.ffi = cffi.FFI()
        
        self.ffi.cdef("""
            typedef struct BatchedSimulatorContext BatchedSimulatorContext;
            BatchedSimulatorContext* bibo_batched_env_create(int num_envs);
            void bibo_batched_env_destroy(BatchedSimulatorContext* ctx);
            
            float* bibo_batched_get_actions_ptr(BatchedSimulatorContext* ctx);
            float* bibo_batched_get_states_ptr(BatchedSimulatorContext* ctx);
            float* bibo_batched_get_rewards_ptr(BatchedSimulatorContext* ctx);
            int*   bibo_batched_get_dones_ptr(BatchedSimulatorContext* ctx);
            
            void bibo_batched_sync_actions_to_device(BatchedSimulatorContext* ctx);
            void bibo_batched_sync_results_to_host(BatchedSimulatorContext* ctx);
            
            void bibo_batched_env_reset_cuda(BatchedSimulatorContext* ctx);
            void bibo_batched_env_step_cuda(BatchedSimulatorContext* ctx, float dt);
        """)
        
        ext = ".dylib" if platform.system() == "Darwin" else ".so"
        lib_path = os.path.abspath(os.path.join(os.path.dirname(__file__), build_dir, f"libbibo_cffi{ext}"))
        
        if not os.path.exists(lib_path):
            raise FileNotFoundError(f"Missing shared library {lib_path}")
            
        self.lib = self.ffi.dlopen(lib_path)
        
        self.ctx = self.lib.bibo_batched_env_create(self.num_envs)
        if not self.ctx:
            raise RuntimeError("Failed to allocate GPU memory.")
            
        # Get raw pointers to pinned memory
        self.actions_ptr = self.lib.bibo_batched_get_actions_ptr(self.ctx)
        self.states_ptr = self.lib.bibo_batched_get_states_ptr(self.ctx)
        self.rewards_ptr = self.lib.bibo_batched_get_rewards_ptr(self.ctx)
        self.dones_ptr = self.lib.bibo_batched_get_dones_ptr(self.ctx)
        
        # Zero-copy NumPy views
        self.actions_view = np.frombuffer(self.ffi.buffer(self.actions_ptr, self.num_envs * 4 * 4), dtype=np.float32).reshape(self.num_envs, 4)
        self.states_view = np.frombuffer(self.ffi.buffer(self.states_ptr, self.num_envs * 21 * 4), dtype=np.float32).reshape(self.num_envs, 21)
        self.rewards_view = np.frombuffer(self.ffi.buffer(self.rewards_ptr, self.num_envs * 4), dtype=np.float32)
        self.dones_view = np.frombuffer(self.ffi.buffer(self.dones_ptr, self.num_envs * 4), dtype=np.int32)
        
        self.dt = 0.01
        
    def __del__(self):
        if hasattr(self, 'lib') and hasattr(self, 'ctx') and self.ctx:
            self.lib.bibo_batched_env_destroy(self.ctx)

    def reset(self):
        self.lib.bibo_batched_env_reset_cuda(self.ctx)
        self.lib.bibo_batched_sync_results_to_host(self.ctx)
        return self.states_view
        
    def step(self):
        # We assume the user has directly written to self.actions_view
        # 1. Sync actions Host -> Device
        self.lib.bibo_batched_sync_actions_to_device(self.ctx)
        
        # 2. Run CUDA Kernel
        self.lib.bibo_batched_env_step_cuda(self.ctx, self.dt)
        
        # 3. Sync Results Device -> Host
        self.lib.bibo_batched_sync_results_to_host(self.ctx)
        
        return self.states_view, self.rewards_view, self.dones_view
