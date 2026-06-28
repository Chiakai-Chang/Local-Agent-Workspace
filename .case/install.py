#!/usr/bin/env python3
# =============================================================================
# C.A.S.E. Framework — Installer and Updater Script (Python)
# =============================================================================
# Usage:  python install.py
# Effect: Installs C.A.S.E. globally for all Agent CLI projects or bootstraps 
#         it locally for a specific repository. Handles both offline execution
#         and online downloading of the full framework files from GitHub.
# =============================================================================

import os
import sys
import shutil
import platform
import zipfile
import tempfile
import urllib.request

def get_global_config_dir():
    """Resolves the global Gemini/Agent configuration directory."""
    home = os.path.expanduser("~")
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

def download_and_extract_case_folder():
    """Downloads the repo zip from GitHub and extracts the .case directory."""
    zip_url = "https://github.com/Chiakai-Chang/Local-Agent-Workspace/archive/refs/heads/main.zip"
    print("🌐 Downloading C.A.S.E. Framework from GitHub...")
    
    temp_dir = tempfile.mkdtemp()
    zip_path = os.path.join(temp_dir, "repo.zip")
    try:
        # Download the zip file
        urllib.request.urlretrieve(zip_url, zip_path)
        
        # Extract .case folder
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # Find all files under the .case directory in the zip
            case_files = [f for f in zip_ref.namelist() if "/.case/" in f]
            
            extract_dest = os.path.join(temp_dir, "extracted_case")
            os.makedirs(extract_dest, exist_ok=True)
            
            for file_info in case_files:
                parts = file_info.split("/.case/", 1)
                if len(parts) == 2 and parts[1]:
                    target_rel_path = parts[1]
                    target_file_path = os.path.join(extract_dest, target_rel_path)
                    
                    os.makedirs(os.path.dirname(target_file_path), exist_ok=True)
                    
                    with zip_ref.open(file_info) as source, open(target_file_path, "wb") as target:
                        target.write(source.read())
                        
        print("✓ Framework files downloaded and extracted successfully.")
        return extract_dest, temp_dir
    except Exception as e:
        print(f"[ERROR] Failed to download or extract zip from GitHub: {e}")
        # Clean up temp folder on failure
        try:
            shutil.rmtree(temp_dir)
        except:
            pass
        return None, None

def run_installer():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Try resolving source skill locally (Offline Mode)
    source_skill = None
    
    # Case 1: Running from cloned repo inside .case/ directory
    if os.path.isfile(os.path.join(script_dir, "SKILL.md")):
        source_skill = script_dir
    # Case 2: Running from within .agents/skills/case-framework/scripts/
    elif os.path.isfile(os.path.join(script_dir, "..", "SKILL.md")):
        source_skill = os.path.abspath(os.path.join(script_dir, ".."))
        
    temp_dir_to_clean = None
    
    # If not found locally, we enter Online Mode (downloading from GitHub)
    if not source_skill:
        print("💡 Local source files not found. Running in ONLINE mode.")
        download_result = download_and_extract_case_folder()
        if download_result[0]:
            source_skill = download_result[0]
            temp_dir_to_clean = download_result[1]
        else:
            print("\n❌ Installation aborted: Could not fetch files from GitHub.")
            sys.exit(1)

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
    
    try:
        if choice == '1':
            global_install(source_skill)
        elif choice == '2':
            local_skill_install(source_skill)
        elif choice == '3':
            scaffold_install(source_skill)
        elif choice == '4':
            update_install(source_skill)
        else:
            print("Exit installer.")
    finally:
        # Clean up downloaded temp directory if it exists
        if temp_dir_to_clean and os.path.exists(temp_dir_to_clean):
            shutil.rmtree(temp_dir_to_clean)

def global_install(source_skill):
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
    target_project = input("\nEnter target project directory path (. for current): ").strip()
    if not target_project:
        target_project = "."
    target_project = os.path.abspath(target_project)
    
    dest_skill = os.path.join(target_project, ".agents", "skills", "case-framework")
    print(f"\nInstalling C.A.S.E. locally to:\n 👉 {dest_skill}")
    
    try:
        copy_directory(source_skill, dest_skill)
        # Also copy skills.json to load it dynamically
        agents_dir = os.path.join(target_project, ".agents")
        os.makedirs(agents_dir, exist_ok=True)
        skills_json_path = os.path.join(agents_dir, "skills.json")
        with open(skills_json_path, 'w', encoding='utf-8') as f:
            f.write('{\n  "entries": [\n    { "path": "skills/case-framework" }\n  ]\n}\n')
        print("\n✅ Local Workspace Skill Installation Complete!")
    except Exception as e:
        print(f"[ERROR] Failed to install locally: {e}")

def scaffold_install(source_skill):
    target_project = input("\nEnter target project directory path (. for current): ").strip()
    if not target_project:
        target_project = "."
    target_project = os.path.abspath(target_project)
    
    # If online, we need to extract bootstrap.py first to run it
    bootstrapper = os.path.join(source_skill, "bootstrap.py")
    if os.path.isfile(bootstrapper):
        # We also need to copy the entire .case directory to the target project first
        target_case = os.path.join(target_project, ".case")
        print(f"Deploying C.A.S.E. harness source to {target_case}...")
        copy_directory(source_skill, target_case)
        
        # Run bootstrapper
        local_bootstrapper = os.path.join(target_case, "bootstrap.py")
        print(f"\nRunning C.A.S.E. Bootstrapper on {target_project}...")
        os.system(f'python "{local_bootstrapper}" "{target_project}"')
    else:
        print("[ERROR] bootstrap.py script not found in source.")

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
