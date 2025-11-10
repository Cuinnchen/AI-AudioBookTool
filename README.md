# AI有声书制作工具

使用AI生成语音的有声书制作工具，支持Cosyvoice2和indexTTS2两种。
使用Gemini或Deepseek进行文章角色和对话分析。
可批量自动化生成小说章节语音文件。

---

## 💻 跨平台支持说明

本项目现已支持 **Windows**、**macOS** 和 **Linux** 系统。

### macOS/Linux 用户快速启动

```bash
# 1. 确保已安装 Python 3.12+
python3 --version

# 2. 创建虚拟环境（如果尚未创建）
python3 -m venv venv

# 3. 激活虚拟环境
source venv/bin/activate

# 4. 安装依赖
pip install -r requirements.txt

# 5. 安装 ffmpeg（用于音频转换）
# macOS:
brew install ffmpeg

# Linux (Ubuntu/Debian):
sudo apt-get install ffmpeg

# 6. 启动服务器
./start_server.sh
# 或者直接运行:
python serverV2.py
```

### Windows 用户快速启动

```cmd
# 使用提供的批处理文件
启动ServerV2.bat
```

---

## ⚠️ 重要依赖说明

### Python 版本
- **推荐**：Python 3.12 - 3.13
- **Python 3.13+ 用户**：项目已自动处理兼容性，会安装 `audioop-lts` 替代已移除的 `audioop` 模块

### FFmpeg 配置

项目启动时会**自动检测**系统中的 ffmpeg：

- **macOS**：`brew install ffmpeg`
- **Linux**：`sudo apt-get install ffmpeg` 或 `sudo yum install ffmpeg`
- **Windows**：
  - 优先使用项目自带的 ffmpeg（放置在 `ffmpeg-8.0-full_build/bin/ffmpeg.exe`）
  - 或将 ffmpeg 添加到系统 PATH

---

## 🚀 核心功能

- 支持多种TTS模型（Cosyvoice2、IndexTTS2）
- 支持多种LLM模型（Gemini、Deepseek/阿里云通义千问）用于角色识别与对话分析
- 批量自动化将小说章节转换为语音
- Web界面交互，支持角色管理、音色配置、内容编辑等

---

## 🛠️ 技术栈

- **后端**：FastAPI + Python 3.12+
- **前端**：HTML + CSS + JavaScript
- **音频处理**：pydub + soundfile + scipy + ffmpeg
- **AI模型**：Gemini API / 阿里云通义千问 API

---

## 🔧 已修复的跨平台兼容性问题

1. **FFmpeg 路径检测**：自动识别 Windows (.exe) 和 Unix 系统的可执行文件
2. **自动回退机制**：如项目目录未找到 ffmpeg，自动使用系统 PATH 中的 ffmpeg
3. **Python 3.13 支持**：自动安装 audioop-lts 替代已移除的 audioop 模块
4. **路径分隔符**：使用 `os.path.join()` 确保跨平台兼容
5. **启动脚本**：提供 macOS/Linux 的 `start_server.sh` 和 Windows 的 `.bat` 文件
