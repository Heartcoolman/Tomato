#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'TomatoTimer.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 获取主target
target = project.targets.first

# 要添加的文件列表
files_to_add = [
  'TomatoTimer/Utilities/GradientLibrary.swift',
  'TomatoTimer/Views/Components/GradientButton.swift',
  'TomatoTimer/Views/Components/StatusCard.swift',
  'TomatoTimer/Views/Components/ModePillSelector.swift',
  'TomatoTimer/Views/Components/ParticleSystem.swift',
  'TomatoTimer/Views/Navigation/DockNavigationBar.swift'
]

# 获取或创建组
utilities_group = project.main_group['TomatoTimer']['Utilities'] || project.main_group['TomatoTimer'].new_group('Utilities')
components_group = project.main_group['TomatoTimer']['Views']['Components'] || project.main_group['TomatoTimer']['Views'].new_group('Components')
navigation_group = project.main_group['TomatoTimer']['Views']['Navigation'] || project.main_group['TomatoTimer']['Views'].new_group('Navigation')

files_to_add.each do |file_path|
  # 检查文件是否已经在项目中
  existing_file = project.files.find { |f| f.path == file_path }
  
  unless existing_file
    # 确定应该添加到哪个组
    if file_path.include?('Utilities')
      file_ref = utilities_group.new_reference(file_path)
    elsif file_path.include?('Navigation')
      file_ref = navigation_group.new_reference(file_path)
    else
      file_ref = components_group.new_reference(file_path)
    end
    
    # 添加到编译源
    target.add_file_references([file_ref])
    
    puts "Added: #{file_path}"
  else
    puts "Already exists: #{file_path}"
  end
end

project.save
puts "Project updated successfully!"

