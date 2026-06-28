#!/usr/bin/env python3
"""
C.A.S.E. Framework — Memory Tiering Manager (SkillOpt)

Automatically manages learnings.md to keep it under the 40-line ceiling.
Moves older entries to archive_learnings.md.
"""

import os
import sys

def manage_memory(project_dir: str):
    learnings_path = os.path.join(project_dir, '00_Constitution', 'learnings.md')
    archive_path = os.path.join(project_dir, '00_Constitution', 'archive_learnings.md')

    if not os.path.isfile(learnings_path):
        print(f"⚠️ learnings.md not found at: {learnings_path}. Skipping memory tiering.")
        return

    with open(learnings_path, 'r', encoding='utf-8') as f:
        lines = [line.replace('\r\n', '\n') for line in f.readlines()]

    # If the file is already under the 40-line limit, do nothing
    if len(lines) <= 40:
        return

    print(f"🧠 learnings.md has {len(lines)} lines, exceeding the 40-line ceiling.")
    print("⏳ Initiating memory tiering: migrating old entries to archive_learnings.md...")

    # Identify list items (learnings). Usually start with '-', '*', or digits.
    header_lines = []
    mistakes_section = []
    patterns_section = []
    
    current_section = None
    
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('#') or not stripped:
            # Header or empty lines
            if 'Anti-Patterns' in line:
                current_section = 'mistakes'
            elif 'Reusable Patterns' in line:
                current_section = 'patterns'
            header_lines.append(line)
            continue
            
        # If it's a list item
        if stripped.startswith('-') or stripped.startswith('*') or (stripped and stripped[0].isdigit()):
            if current_section == 'mistakes':
                mistakes_section.append(line)
            elif current_section == 'patterns':
                patterns_section.append(line)
            else:
                header_lines.append(line)
        else:
            header_lines.append(line)

    # Let's see how many items we have
    total_items = len(mistakes_section) + len(patterns_section)
    if total_items == 0:
        print("⚠️ No list item entries found to migrate. Truncating file raw lines.")
        # Fallback: just keep the last 30 lines
        header_lines = lines[:10]
        content_lines = lines[10:]
        migrated = content_lines[:-30]
        remaining = content_lines[-30:]
        write_files(learnings_path, archive_path, header_lines + remaining, migrated)
        return

    # Decide how many items to migrate (e.g. migrate 5 oldest items or 30% of items)
    # Assume the top items in each section are the oldest (fifo)
    migrated_items = []
    remaining_mistakes = list(mistakes_section)
    remaining_patterns = list(patterns_section)

    # Migrate up to 3 from mistakes and 3 from patterns
    to_migrate_mistakes = max(0, len(remaining_mistakes) - 8)
    to_migrate_patterns = max(0, len(remaining_patterns) - 8)

    if to_migrate_mistakes > 0:
        migrated_items.extend(remaining_mistakes[:to_migrate_mistakes])
        remaining_mistakes = remaining_mistakes[to_migrate_mistakes:]

    if to_migrate_patterns > 0:
        migrated_items.extend(remaining_patterns[:to_migrate_patterns])
        remaining_patterns = remaining_patterns[to_migrate_patterns:]

    # Reconstruct learnings.md content
    new_learnings_content = []
    current_section = None
    
    for line in lines:
        stripped = line.strip()
        if stripped.startswith('#') or not stripped:
            if 'Anti-Patterns' in line:
                current_section = 'mistakes'
                new_learnings_content.append(line)
                continue
            elif 'Reusable Patterns' in line:
                current_section = 'patterns'
                new_learnings_content.append(line)
                continue
            new_learnings_content.append(line)
            continue
            
        if stripped.startswith('-') or stripped.startswith('*') or (stripped and stripped[0].isdigit()):
            # Skip writing here; we'll append remaining lists under their headers
            continue
        new_learnings_content.append(line)

    # Now inject the remaining items under their respective headers
    final_content = []
    for line in new_learnings_content:
        final_content.append(line)
        if 'Anti-Patterns' in line:
            final_content.extend(remaining_mistakes)
            final_content.append("\n")
        elif 'Reusable Patterns' in line:
            final_content.extend(remaining_patterns)
            final_content.append("\n")

    write_files(learnings_path, archive_path, final_content, migrated_items)

def write_files(learnings_path, archive_path, learnings_content, migrated_items):
    # Ensure archive file exists
    archive_header = "# 🗄️ C.A.S.E. Cold Memory Archive (Archive Learnings)\n\n"
    existing_archive_content = []
    if os.path.isfile(archive_path):
        with open(archive_path, 'r', encoding='utf-8') as f:
            existing_archive_content = [line.replace('\r\n', '\n') for line in f.readlines()]
            # remove header if exists to avoid duplication
            if existing_archive_content and existing_archive_content[0].startswith('#'):
                existing_archive_content = existing_archive_content[2:]
    
    # Write learnings.md
    with open(learnings_path, 'w', encoding='utf-8', newline='\n') as f:
        f.writelines(learnings_content)

    # Prepend migrated items to archive_learnings.md
    with open(archive_path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(archive_header)
        f.writelines(migrated_items)
        f.write("\n")
        f.writelines(existing_archive_content)

    print(f"✅ Successfully migrated {len(migrated_items)} old entries to archive_learnings.md.")
    print("      ✓ learnings.md line size reduced.")

if __name__ == '__main__':
    project_root = sys.argv[1] if len(sys.argv) > 1 else "."
    manage_memory(os.path.abspath(project_root))
