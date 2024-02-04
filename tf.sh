function tfcheck() {

# 检查是否安装了 Terraform
if command -v terraform &> /dev/null; then
  terraform_version=$(terraform --version | head -n 1 | awk '{print $2}')
  echo "Terraform 已安装，版本为 $terraform_version。"

else
  sudo dnf install -y dnf-plugins-core
  sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  sudo dnf -y install terraform
fi
}

function terraforminit() {
  rm -rf exe.log
  terraform init
}
function exec() {

# TRACE: 最详细的日志级别，显示所有操作步骤。
# DEBUG: 显示调试信息，比 TRACE 日志级别少一些。
# INFO: 默认级别，显示关键信息。
# WARN: 只显示警告和错误信息。
# ERROR: 只显示错误信息。
export TF_LOG=DEBUG
# -auto-approve忽略提示确认
# -parallelism=1设置并发数
export TF_CLI_ARGS="-auto-approve -parallelism=1"


# 设置脚本在任何命令返回非零退出状态时立即退出
set -e

# 创建一个关联数组（映射）
declare -A modules

# 用于给模块分配数字键的计数器
count=1

# 读取 Terraform 文件，提取模块信息并填充映射
while IFS= read -r line; do
  if [[ $line =~ ^module\ (.+)\ \{ ]]; then
    module_name=${BASH_REMATCH[1]}
    # 移除模块名称中的双引号
    module_name=${module_name//\"/}
    modules["$count"]=$module_name
    ((count++))
  fi
done < main.tf

# 打印映射中的信息
echo "序号   module名称"
for key in $(echo "${!modules[@]}" | tr ' ' '\n' | sort -n); do
  printf "%-6s |   %s\n" "$key" "${modules[$key]}"
done

# 读取用户输入
read -r -p "请输入要执行的module序号或输入 \"install\" 执行所有模块，跳过键为 "init"、"container" 或 "ping" 的模块: " keyread
# 检查用户输入是否有效
if [[ -n "${modules[$keyread]}" ]]; then
  rm -rf terraform.tfstate && terraform apply -target=module.${modules[$keyread]}
  if [[ "${modules[$keyread]}" == "container" ]]; then 
     bash down.sh containerd
  fi

elif [[ "$keyread" == "install" ]]; then
  # 获取模块数量
  module_count=${#modules[@]}
  # 遍历模块数组
  for ((count=1; count <= module_count; count++)); do
    # 获取模块名称
    module_name=${modules[$count]}
    
    # 跳过键为 "init"、 或 "ping" 的模块
    if [[ "$module_name" != "init" && "$module_name" != "ping" ]]; then
      echo "rm -rf terraform.tfstate && terraform apply -target=module.$module_name" >> exe.log
      rm -rf terraform.tfstate && terraform apply -target=module.$module_name
      if [[ "${modules[$keyread]}" == "container" ]]; then 
        bash down.sh containerd
      fi
      sleep 2
    else
      echo "跳过模块 $module_name。"
    fi
  done

else
  echo "无效的输入"
fi
}


tfcheck
terraforminit
exec

