#!/usr/bin/env python3
# =============================================================================
# C.A.S.E. Framework — Installer and Updater Script (Python)
# =============================================================================
# Usage:  python install.py
# Effect: Installs C.A.S.E. globally for all Agent CLI projects or bootstraps 
#         it locally for a specific repository.
# =============================================================================

import os
import sys
import shutil
import platform

def get_global_config_dir():
    """Resolves the global Gemini/Agent configuration directory."""
    home = os.path.expanduser("~")
    # Check OS
    if platform.system() == "Windows":
        # Windows standard path: C:\Users\USER\.gemini\config
        return os.path.join(home, ".gemini", "config")
    else:
        # macOS/Linux standard path: ~/.gemini/config
        return os.path.join(home, ".gemini", "config")

def copy_directory(src, dest):
    """Copies directory contents recursively, overwriting existing files."""
    if not os.path.exists(dest):
        os.makedirs(dest)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dest, item)
        if os.path.isdir(s):
            copy_directory(s, d)
        else:
            shutil.copy2(s, d)

def run_installer():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # The source skill path is either sibling to this script or in parent
    source_skill = os.path.abspath(os.path.join(script_dir, "..", "skills", "case-framework"))
    if not os.path.isdir(source_skill):
        # Sibling check (if run from inside the skill's scripts directory)
        source_skill = os.path.abspath(os.path.join(script_dir, ".."))
        if not os.path.isfile(os.path.join(source_skill, "SKILL.md")):
            # Fallback to root workspace skill source
            source_skill = os.path.abspath(os.path.join(script_dir, ".agents", "skills", "case-framework"))

    print("========================================================")
    print(" 🚀 C.A.S.E. Framework — Skill Installer & Updater")
    print("========================================================")
    print("Select installation target:")
    print("  [1] Global Install  - Enable C.A.S.E. globally for all projects")
    print("  [2] Local Project   - Install as a local Workspace Skill (.agents/)")
    print("  [3] Scaffold Only   - Bootstrap C.A.S.E. directories in current project")
    print("  [4] Update Skill    - Update existing global/local install")
    print("  [q] Quit")
    
    choice = input("\nEnter choice (1/2/3/4/q): ").strip().lower()
    
    if choice == '1':
        global_install(source_skill)
    elif choice == '2':
        local_skill_install(source_skill)
    elif choice == '3':
        scaffold_install()
    elif choice == '4':
        update_install(source_skill)
    else:
        print("Exit installer.")

def global_install(source_skill):
    if not os.path.isdir(source_skill):
        print(f"[ERROR] Source skill directory not found: {source_skill}")
        return
        
    global_dir = get_global_config_dir()
    dest_skill = os.path.join(global_dir, "skills", "case-framework")
    
    print(f"\nInstalling C.A.S.E. globally to:\n 👉 {dest_skill}")
    try:
        copy_directory(source_skill, dest_skill)
        print("\n✅ Global Skill Installation Complete!")
        print("🤖 Any agent session starting in any repo will now automatically support C.A.S.E. triggers.")
    except Exception as e:
        print(f"[ERROR] Failed to write to global directory: {e}")

def local_skill_install(source_skill):
    if not os.path.isdir(source_skill):
        print(f"[ERROR] Source skill directory not found: {source_skill}")
        return
        
    target_project = input("\nEnter target project directory path (. for current): ").strip()
    if not target_project:
        target_project = "."
    target_project = os.path.abspath(target_project)
    
    dest_skill = os.path.join(target_project, ".agents", "skills", "case-framework")
    print(f"\nInstalling C.A.S.E. locally to:\n 👉 {dest_skill}")
    
    try:
        copy_directory(source_skill, dest_skill)
        print("\n✅ Local Workspace Skill Installation Complete!")
    except Exception as e:
        print(f"[ERROR] Failed to install locally: {e}")

def scaffold_install():
    target_project = input("\nEnter target project directory path (. for current): ").strip()
    if not target_project:
        target_project = "."
    target_project = os.path.abspath(target_project)
    
    # Locate bootstrap.py
    script_dir = os.path.dirname(os.path.abspath(__file__))
    bootstrapper = os.path.join(script_dir, "bootstrap.py")
    if not os.path.isfile(bootstrapper):
        bootstrapper = os.path.join(script_dir, "scripts", "bootstrap.py")
        if not os.path.isfile(bootstrapper):
            bootstrapper = os.path.abspath(os.path.join(script_dir, "..", "bootstrap.py"))
            
    if os.path.isfile(bootstrapper):
        print(f"\nRunning C.A.S.E. Bootstrapper on {target_project}...")
        os.system(f'python "{bootstrapper}" "{target_project}"')
    else:
        print("[ERROR] bootstrap.py script not found.")

def update_install(source_skill):
    print("\nUpdating existing installations...")
    global_dir = get_global_config_dir()
    global_skill = os.path.join(global_dir, "skills", "case-framework")
    
    updated_any = False
    
    if os.path.isdir(global_skill):
        print(f"Updating Global Install: {global_skill}")
        copy_directory(source_skill, global_skill)
        print("  ✓ Global skill updated.")
        updated_any = True
        
    if os.path.isdir(".agents/skills/case-framework"):
        print(f"Updating Local Project Skill: .agents/skills/case-framework")
        copy_directory(source_skill, ".agents/skills/case-framework")
        print("  ✓ Local skill updated.")
        updated_any = True
        
    if updated_any:
        print("\n✅ Update completed successfully!")
    else:
        print("\n⚠️ No existing C.A.S.E. installations detected to update.")
        print("Please choose options [1] or [2] to perform a clean install first.")

if __name__ == "__main__":
    run_installer()
