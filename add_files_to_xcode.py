#!/usr/bin/env python3
"""
自动将新文件添加到 Xcode 项目
"""

import re

# 读取项目文件
with open('TomatoTimer.xcodeproj/project.pbxproj', 'r', encoding='utf-8') as f:
    content = f.read()

# 新文件的定义
new_files = {
    # Models
    'A200': ('Book.swift', 'Models'),
    'A202': ('WebDAVAccount.swift', 'Models'),
    'A204': ('ReaderSettings.swift', 'Models'),
    
    # Core
    'A206': ('WebDAVManager.swift', 'Core'),
    'A208': ('EncodingDetector.swift', 'Core'),
    'A210': ('ChapterParser.swift', 'Core'),
    
    # Stores
    'A212': ('BookStore.swift', 'Stores'),
    
    # Views/Reader
    'A214': ('ReaderMainView.swift', 'Views/Reader'),
    'A216': ('WebDAVFileListView.swift', 'Views/Reader'),
    'A218': ('AddWebDAVAccountView.swift', 'Views/Reader'),
    'A220': ('BookReaderView.swift', 'Views/Reader'),
    'A222': ('EncodingPickerView.swift', 'Views/Reader'),
}

# 1. 添加 PBXBuildFile 条目
build_file_section = re.search(r'/\* Begin PBXBuildFile section \*/\n(.*?)/\* End PBXBuildFile section \*/', content, re.DOTALL)
if build_file_section:
    last_build_file = build_file_section.group(1).strip().split('\n')[-1]
    new_build_files = []
    
    for file_id, (filename, _) in new_files.items():
        build_id = f"A{int(file_id[1:]) + 1}"
        new_build_files.append(f"\t\t{build_id} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_id}; }};")
    
    insert_pos = content.find('/* End PBXBuildFile section */')
    content = content[:insert_pos] + '\n'.join(new_build_files) + '\n' + content[insert_pos:]

# 2. 添加 PBXFileReference 条目
file_ref_section = re.search(r'/\* Begin PBXFileReference section \*/\n(.*?)/\* End PBXFileReference section \*/', content, re.DOTALL)
if file_ref_section:
    new_file_refs = []
    
    for file_id, (filename, path) in new_files.items():
        new_file_refs.append(f"\t\t{file_id} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};")
    
    insert_pos = content.find('/* End PBXFileReference section */')
    content = content[:insert_pos] + '\n'.join(new_file_refs) + '\n' + content[insert_pos:]

# 3. 添加到 MODELS 组
models_group = re.search(r'MODELS = \{\s*isa = PBXGroup;\s*children = \((.*?)\);', content, re.DOTALL)
if models_group:
    models_children = models_group.group(1).strip()
    new_models = ['A200', 'A202', 'A204']
    for model_id in new_models:
        if model_id not in models_children:
            models_children += f',\n\t\t\t\t{model_id}'
    
    content = re.sub(
        r'(MODELS = \{\s*isa = PBXGroup;\s*children = \().*?(\);)',
        f'\\1{models_children}\\2',
        content,
        flags=re.DOTALL
    )

# 4. 添加到 CORE 组
core_group = re.search(r'CORE = \{\s*isa = PBXGroup;\s*children = \((.*?)\);', content, re.DOTALL)
if core_group:
    core_children = core_group.group(1).strip()
    new_cores = ['A206', 'A208', 'A210']
    for core_id in new_cores:
        if core_id not in core_children:
            core_children += f',\n\t\t\t\t{core_id}'
    
    content = re.sub(
        r'(CORE = \{\s*isa = PBXGroup;\s*children = \().*?(\);)',
        f'\\1{core_children}\\2',
        content,
        flags=re.DOTALL
    )

# 5. 添加到 STORES 组
stores_group = re.search(r'STORES = \{\s*isa = PBXGroup;\s*children = \((.*?)\);', content, re.DOTALL)
if stores_group:
    stores_children = stores_group.group(1).strip()
    if 'A212' not in stores_children:
        stores_children += ',\n\t\t\t\tA212'
    
    content = re.sub(
        r'(STORES = \{\s*isa = PBXGroup;\s*children = \().*?(\);)',
        f'\\1{stores_children}\\2',
        content,
        flags=re.DOTALL
    )

# 6. 创建 READER 组并添加到 VIEWS
reader_group = """	READER = {
		isa = PBXGroup;
		children = (
			A214,
			A216,
			A218,
			A220,
			A222,
		);
		path = Reader;
		sourceTree = "<group>";
	};"""

# 在 VIEWS 组中添加 READER
views_group = re.search(r'VIEWS = \{\s*isa = PBXGroup;\s*children = \((.*?)\);', content, re.DOTALL)
if views_group:
    views_children = views_group.group(1).strip()
    if 'READER' not in views_children:
        views_children += ',\n\t\t\tREADER'
    
    content = re.sub(
        r'(VIEWS = \{\s*isa = PBXGroup;\s*children = \().*?(\);)',
        f'\\1{views_children}\\2',
        content,
        flags=re.DOTALL
    )

# 在 GAME 组后添加 READER 组定义
game_group_end = content.find('path = Game;')
if game_group_end > 0:
    next_section = content.find('};', game_group_end)
    if next_section > 0:
        insert_pos = content.find('\n', next_section) + 1
        content = content[:insert_pos] + reader_group + '\n' + content[insert_pos:]

# 7. 添加到编译源列表
sources_section = re.search(r'APPSOURCES = \{\s*isa = PBXSourcesBuildPhase;.*?files = \((.*?)\);', content, re.DOTALL)
if sources_section:
    sources_files = sources_section.group(1).strip()
    
    new_source_files = []
    for file_id, (filename, _) in new_files.items():
        build_id = f"A{int(file_id[1:]) + 1}"
        new_source_files.append(f"\t\t\t\t{build_id} /* {filename} in Sources */,")
    
    # 在最后一个 A157 后添加
    insert_marker = 'A157 /* DockNavigationBar.swift in Sources */,'
    insert_pos = content.find(insert_marker)
    if insert_pos > 0:
        insert_pos = content.find('\n', insert_pos) + 1
        content = content[:insert_pos] + '\n'.join(new_source_files) + '\n' + content[insert_pos:]

# 写回文件
with open('TomatoTimer.xcodeproj/project.pbxproj', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ 成功添加文件到 Xcode 项目！")
print("\n添加的文件：")
for file_id, (filename, path) in new_files.items():
    print(f"  - {path}/{filename}")
