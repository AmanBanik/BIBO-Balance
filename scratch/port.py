import os
import re

types = r'(void|int|float|Vec3|Quat|ContactInfo|PlatformState|PlatformGeometry|BiboSimulator\*|BiboSimulator)'
# Match: Start of line -> optional spaces -> Type -> Space -> FunctionName -> (
regex = re.compile(r'^(\s*)' + types + r'\s+(\w+)\s*\(', re.MULTILINE)

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # If it's a header, inject the cuda_utils include
    if filepath.endswith('.h') and 'cuda_utils.h' not in content:
        # Avoid putting it in cuda_utils.h itself
        if 'BIBO_CUDA_UTILS_H' not in content:
            content = re.sub(r'(#define BIBO_[A-Z_]+_H\n)', r'\1\n#include "bibo/cuda_utils.h"\n', content, count=1)
            
    # Apply BIBO_FUNC replacement (avoiding double application)
    def replacer(match):
        spaces = match.group(1)
        ret_type = match.group(2)
        func_name = match.group(3)
        # Skip if already has BIBO_FUNC
        # The regex won't match "BIBO_FUNC float" because BIBO_FUNC isn't in the types list, 
        # but just to be safe, check the previous text.
        return f'{spaces}BIBO_FUNC {ret_type} {func_name}('
        
    new_content = regex.sub(replacer, content)
    
    # Fix the test files that might have been modified incorrectly (they don't need BIBO_FUNC for main)
    if filepath.endswith('.c') and 'tests/unit' in filepath:
        new_content = new_content.replace('BIBO_FUNC int main(', 'int main(')
        
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print(f"Processed {filepath}")

def main():
    dirs_to_scan = ['include/bibo', 'src/core', 'src/geometry', 'src/physics']
    for d in dirs_to_scan:
        for filename in os.listdir(d):
            if filename.endswith('.h') or filename.endswith('.c'):
                process_file(os.path.join(d, filename))

if __name__ == '__main__':
    main()
