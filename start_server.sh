#!/bin/bash
# AI-AudioBookTool 启动脚本 (macOS/Linux)

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 检查虚拟环境
if [ ! -d "venv" ]; then
    echo "❌ 未找到虚拟环境，请先创建虚拟环境："
    echo "   python3 -m venv venv"
    echo "   source venv/bin/activate"
    echo "   pip install -r requirements.txt"
    exit 1
fi

# 激活虚拟环境
source venv/bin/activate

# 检查依赖
if ! python -c "import fastapi, uvicorn, pydub" 2>/dev/null; then
    echo "❌ 缺少依赖，正在安装..."
    pip install -r requirements.txt
fi

# 检查 ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "⚠️  未检测到 ffmpeg，音频转换功能可能受限"
    echo "   建议安装: brew install ffmpeg"
    echo ""
fi

# 启动服务器
echo "🚀 启动 AI-AudioBookTool 服务器..."
python serverV2.py "$@"
