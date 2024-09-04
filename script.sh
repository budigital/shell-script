#!/bin/bash

# The template project to duplicate
source_folder="./childapp-base"

# The config file
project_config_file="project-config.json"

# Check if config file is exists
if [ ! -e $project_config_file ]; then
  echo "Missing '$project_config_file' file."
  exit 1
fi

# # Ask for app name
read -p "Enter the name of the new app (eg: my-new-app): " app_name

# Ask for folder name
read -p "Enter the name of the new app folder (eg: My_New_App): " dir_name

# Check if the desired folder name already exists
if [ -d "$dir_name" ]; then
  echo "The folder '$dir_name' already exists."
  exit 1
fi

# Ask for application port number
read -p "Enter the desired running port (eg: 9000): " port_number

# Copy the source folder with desired folder name
cp -r "$source_folder" "$dir_name"

# Check if there was an error during folder creation
if [ $? -eq 1 ]; then
  echo "An error occured while creating folder."
  exit 1
fi

# Create a temporary config file
temp_config_file="temp-config.json"

# Remove the closing square bracket at the end of the file and copy the content to the temporary config file
sed '$d' $project_config_file > $temp_config_file

# Add comma right after the latest closing curly bracket
sed -i '' -e '$s/}/},/' $temp_config_file

# Store the new app config into variable
new_app_config='
\t{\n
  \t\t"app_name": "'$app_name'",\n
  \t\t"dir_name": "'$dir_name'",\n
  \t\t"port": '$port_number'\n
\t}
'

# Print the new app config into temporary config file
echo $new_app_config >> $temp_config_file

# Add closing square bracket at the end of the file
echo "]" >> $temp_config_file

# Replace the temporary config file name with the original one
mv $temp_config_file $project_config_file

# Default configs from the source_folder
default_app_name="childapp-base-app"
default_port=4200
default_lib_name="childapp-base"

# Set CWD to the newly created folder
cd $dir_name

# Search and replace default_app_name within package.json file
sed -i '' "s/${default_app_name}/${app_name}/" "package.json"

if [ $? -eq 1 ]; then
  echo "An error occured while updating the 'default_app_name'."
  echo "Please do it manually by updating the 'package.json' file within the newly created app folder."
fi

# Search and replace all default port number within package.json file
sed -i '' "s/${default_port}/${port_number}/g" "package.json"

if [ $? -eq 1 ]; then
  echo "An error occured while updating the 'default_port'."
  echo "Please do it manually by updating the 'package.json' file within the newly created app folder."
fi

# Search and replace default_lib_name within webpack.config.dev.js file
sed -i '' "s/${default_lib_name}/${app_name}/" "webpack.config.dev.js"

if [ $? -eq 1 ]; then
  echo "An error occured while updating the 'default_lib_name'."
  echo "Please do it manually by updating the 'webpack.config.dev.js' file within the newly created app folder."
fi

# Search and replace default_lib_name within webpack.config.prod.js file
sed -i '' "s/${default_lib_name}/${app_name}/" "webpack.config.prod.js"

if [ $? -eq 1 ]; then
  echo "An error occured while updating the 'default_lib_name'."
  echo "Please do it manually by updating the 'webpack.config.prod.js' file within the newly created app folder."
fi

echo "Successfully created '$app_name' on '$dir_name'."
