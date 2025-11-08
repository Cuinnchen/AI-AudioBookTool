# API参考

<cite>
**Referenced Files in This Document**   
- [serverV2.py](file://serverV2.py)
- [config.json](file://config.json)
</cite>

## 目录
1. [简介](#简介)
2. [API端点参考](#api端点参考)
3. [认证与安全性](#认证与安全性)
4. [速率限制与超时](#速率限制与超时)
5. [API调用依赖关系](#api调用依赖关系)
6. [调试建议](#调试建议)

## 简介
本API参考文档详细描述了AI有声书制作工具后端服务（serverV2.py）中所有公开的RESTful API端点。该服务基于FastAPI框架构建，旨在实现小说文本的自动化处理、语音合成（TTS）、音频拼接与下载等功能。API设计遵循标准化原则，每个端点均提供HTTP方法、URL路径、请求参数、请求体结构、响应格式、错误码及使用示例。系统通过`config.json`文件进行全局配置管理，支持Gemini和阿里云（Deepseek）等LLM模型进行文本分析，并通过CosyVoice2或IndexTTS等TTS模型生成语音。

**Section sources**
- [serverV2.py](file://serverV2.py#L47-L48)
- [README.md](file://README.md#L1-L5)

## API端点参考

### /api/upload_txt_novel (POST)
上传一个TXT格式的小说文件。

**HTTP方法**: `POST`
**URL路径**: `/api/upload_txt_novel`

**请求参数**:
- **类型**: `multipart/form-data`
- **字段**: `file` (UploadFile, 必需) - 要上传的TXT文件。

**请求体结构**:
无独立的JSON结构，通过`multipart/form-data`表单上传文件。

**响应格式**:
```json
{
  "status": "success",
  "message": "小说 '{novel_name}' 已成功上传并统一转换为UTF-8。",
  "chapters": [
    {"id": 0, "title": "第一章 起始"},
    {"id": 1, "title": "第二章 发展"}
  ]
}
```

**错误码**:
- `400`: 上传的文件为空。
- `500`: 服务器处理文件失败（如解码错误、IO错误）。

**示例**:
- **curl命令**:
  ```bash
  curl -X POST "http://localhost:8000/api/upload_txt_novel" -H "Content-Type: multipart/form-data" -F "file=@/path/to/novel.txt"
  ```
- **JavaScript fetch**:
  ```javascript
  const formData = new FormData();
  formData.append('file', fileInput.files[0]);
  fetch('/api/upload_txt_novel', { method: 'POST', body: formData })
    .then(response => response.json())
    .then(data => console.log(data));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1543-L1607)

### /api/list_novels (GET)
获取所有已上传小说的列表及其处理状态。

**HTTP方法**: `GET`
**URL路径**: `/api/list_novels`

**请求参数**: 无

**请求体结构**: 无

**响应格式**:
```json
{
  "novels_details": {
    "小说名1": {
      "chapters": [
        {"id": 0, "title": "第一章", "processed": true, "spliced": false},
        {"id": 1, "title": "第二章", "processed": false, "spliced": false}
      ],
      "isTxtProject": true
    }
  }
}
```

**错误码**: 无

**示例**:
- **curl命令**:
  ```bash
  curl -X GET "http://localhost:8000/api/list_novels"
  ```
- **JavaScript fetch**:
  ```javascript
  fetch('/api/list_novels')
    .then(response => response.json())
    .then(data => console.log(data.novels_details));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1610-L1663)

### /api/process_single_chapter (POST)
处理单个小说章节，将其转换为带有角色、语气等信息的JSON格式。

**HTTP方法**: `POST`
**URL路径**: `/api/process_single_chapter`

**请求参数**: 无

**请求体结构 (JSON Schema)**:
```json
{
  "novel_name": "string",
  "chapter_title": "string",
  "model_name": "string", // 可选，用于指定LLM模型
  "force_regenerate": "boolean", // 可选，是否强制重新生成
  "preview_only": "boolean" // 可选，是否仅预览原文
}
```

**响应格式**:
- 成功时:
  ```json
  {"status": "success", "message": "章节 '第一章' 处理成功。"}
  ```
- 预览模式:
  ```json
  {"status": "preview", "content": "这是章节的原始文本内容..."}
  ```

**错误码**:
- `400`: 缺少`model_name`或章节标题不存在。
- `404`: 小说或章节文件未找到。
- `500`: 服务器内部错误。

**示例**:
- **curl命令**:
  ```bash
  curl -X POST "http://localhost:8000/api/process_single_chapter" -H "Content-Type: application/json" -d '{"novel_name": "小说名1", "chapter_title": "第一章", "model_name": "gemini"}'
  ```
- **JavaScript fetch**:
  ```javascript
  fetch('/api/process_single_chapter', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ novel_name: '小说名1', chapter_title: '第一章', model_name: 'gemini' })
  });
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1081-L1229)

### /api/tts_v2 (POST)
为指定的文本行生成语音。

**HTTP方法**: `POST`
**URL路径**: `/api/tts_v2`

**请求参数**: 无

**请求体结构 (JSON Schema)**:
```json
{
  "novel_name": "string",
  "chapter_name": "string",
  "row_index": "integer",
  "speaker": "string",
  "timbre": "string",
  "tts_text": "string",
  "prompt_audio": "string", // base64编码的音频
  "prompt_text": "string",
  "inference_mode": "string",
  "instruct_text": "string", // 可选
  "tts_model": "string" // 可选，指定TTS模型
}
```

**响应格式**:
```json
{"status": "success", "file_name": "0001-角色名-音色名.wav"}
```

**错误码**:
- `400`: TTS模型配置无效。
- `503`: 无法连接到TTS微服务。
- `500`: 服务器内部错误。

**示例**:
- **curl命令**:
  ```bash
  curl -X POST "http://localhost:8000/api/tts_v2" -H "Content-Type: application/json" -d '{"novel_name": "小说名1", "chapter_name": "第一章", "row_index": 1, "speaker": "张三", "timbre": "男声1", "tts_text": "你好世界", "prompt_audio": "...", "prompt_text": "你好", "inference_mode": "i"}'
  ```
- **JavaScript fetch**:
  ```javascript
  fetch('/api/tts_v2', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(ttsRequestData)
  });
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1728-L1862)

### /api/splice_audio (POST)
按章节顺序拼接已生成的单句音频文件。

**HTTP方法**: `POST`
**URL路径**: `/api/splice_audio`

**请求参数**: 无

**请求体结构 (JSON Schema)**:
```json
{
  "novel_name": "string",
  "chapter_name": "string"
  // "wav_files" 字段已废弃，后端根据JSON文件自动生成文件列表
}
```

**响应格式**:
```json
{"status": "success", "file_path": "/output/小说名1/第一章.mp3"}
```

**错误码**:
- `400`: 没有可拼接的音频文件。
- `404`: 章节JSON文件未找到。
- `500`: 拼接音频失败。

**示例**:
- **curl命令**:
  ```bash
  curl -X POST "http://localhost:8000/api/splice_audio" -H "Content-Type: application/json" -d '{"novel_name": "小说名1", "chapter_name": "第一章"}'
  ```
- **JavaScript fetch**:
  ```javascript
  fetch('/api/splice_audio', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ novel_name: '小说名1', chapter_name: '第一章' })
  });
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1864-L1956)

### /api/download_spliced_chapters (POST)
将指定的已拼接音频文件打包并下载。

**HTTP方法**: `POST`
**URL路径**: `/api/download_spliced_chapters`

**请求参数**: 无

**请求体结构 (JSON Schema)**:
```json
{
  "file_paths": ["string"] // 文件路径列表，如 ["小说名1/第一章.mp3", "小说名1/第二章.mp3"]
}
```

**响应格式**: 返回一个ZIP格式的文件流。

**错误码**:
- `400`: 未提供文件路径。
- `404`: 所有请求的文件都不存在或不合法。

**示例**:
- **curl命令**:
  ```bash
  curl -X POST "http://localhost:8000/api/download_spliced_chapters" -H "Content-Type: application/json" -d '{"file_paths": ["小说名1/第一章.mp3", "小说名1/第二章.mp3"]}' -o "chapters_spliced.zip"
  ```
- **JavaScript fetch**:
  ```javascript
  fetch('/api/download_spliced_chapters', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ file_paths: ['小说名1/第一章.mp3'] })
  }).then(response => {
    response.blob().then(blob => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'chapters_spliced.zip';
      a.click();
    });
  });
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L2350-L2410)

### /api/get_llm_config (GET/PUT)
读取和更新全局LLM配置。

**HTTP方法**: `GET`, `PUT`
**URL路径**: `/api/get_llm_config`

**GET请求**:
- **请求参数**: 无
- **响应格式**: 返回`config.json`文件内容。

**PUT请求**:
- **请求参数**: 无
- **请求体结构 (JSON Schema)**:
  ```json
  {"config": { /* config.json的完整内容 */ }}
  ```
- **响应格式**:
  ```json
  {"status": "success", "message": "模型配置已成功保存。"}
  ```

**错误码**:
- `404`: `config.json`文件未找到 (GET)。
- `500`: 写入配置文件失败 (PUT)。

**示例**:
- **curl命令 (GET)**:
  ```bash
  curl -X GET "http://localhost:8000/api/get_llm_config"
  ```
- **curl命令 (PUT)**:
  ```bash
  curl -X PUT "http://localhost:8000/api/update_llm_config" -H "Content-Type: application/json" -d '{"config": { ... }}'
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L247-L262)

### /api/stt_elevenlabs (POST)
上传音频文件，使用ElevenLabs API进行语音识别（STT）。

**HTTP方法**: `POST`
**URL路径**: `/api/stt_elevenlabs`

**请求参数**:
- **类型**: `multipart/form-data`
- **字段**: `file` (UploadFile, 必需) - 要识别的音频文件。

**请求体结构**: 无独立的JSON结构，通过`multipart/form-data`表单上传文件。

**响应格式**:
```json
{"status": "success", "text": "识别出的文本内容"}
```

**错误码**:
- `401`: ElevenLabs API Key无效。
- `503`: 服务器未配置API Key或连接失败。
- `500`: 服务器内部错误。

**示例**:
- **curl命令**:
  ```bash
  curl -X POST "http://localhost:8000/api/stt_elevenlabs" -H "Content-Type: multipart/form-data" -F "file=@/path/to/audio.wav"
  ```
- **JavaScript fetch**:
  ```javascript
  const formData = new FormData();
  formData.append('file', audioFile);
  fetch('/api/stt_elevenlabs', { method: 'POST', body: formData })
    .then(response => response.json())
    .then(data => console.log(data.text));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L2413-L2490)

## 认证与安全性
本API目前未实现基于Token或API Key的认证机制，主要依赖于以下安全措施：
1.  **路径遍历防护**: 所有涉及文件路径的操作（如`/api/delete_novel`, `/api/download_spliced_chapters`）都使用`os.path.abspath()`和`startswith()`进行校验，确保请求的路径不会超出`PROJECTS_DIR`或`OUTPUT_DIR`等预定义的根目录，防止恶意用户访问系统其他文件。
2.  **输入验证**: 使用Pydantic模型（如`ProcessSingleChapterRequest`, `TTSRequestV2`）对传入的JSON数据进行严格的类型和格式验证。
3.  **敏感信息隔离**: API Key等敏感信息存储在`config.json`文件中，不直接暴露在代码里。前端通过`/api/get_llm_config`获取配置时，会过滤掉`api_key`字段。

**Section sources**
- [serverV2.py](file://serverV2.py#L897-L945)
- [serverV2.py](file://serverV2.py#L2350-L2410)

## 速率限制与超时
- **速率限制**: 当前API未实现显式的速率限制（Rate Limiting）。但由于后端处理（尤其是LLM和TTS调用）本身耗时较长，天然具备一定的防滥用能力。
- **超时设置**:
  - **TTS请求**: 后端调用TTS微服务时设置了300秒的超时（`timeout=300`）。
  - **STT请求**: 调用ElevenLabs API时设置了120秒的超时（`timeout=120`）。
  - **LLM请求**: 调用Gemini或阿里云API时也设置了300秒的超时。

**Section sources**
- [serverV2.py](file://serverV2.py#L1772)
- [serverV2.py](file://serverV2.py#L2446)
- [serverV2.py](file://serverV2.py#L323)

## API调用依赖关系
API的调用具有严格的先后顺序依赖：
1.  **基础**: 必须先调用 `/api/upload_txt_novel` 上传小说，才能进行后续操作。
2.  **文本处理**: 在调用 `/api/tts_v2` 生成语音前，必须先调用 `/api/process_single_chapter` 处理章节，以生成包含角色、语气等信息的JSON文件。
3.  **音频生成**: `/api/splice_audio` 依赖于 `/api/tts_v2` 生成的单句WAV文件。
4.  **打包下载**: `/api/download_spliced_chapters` 依赖于 `/api/splice_audio` 生成的最终音频文件。

**Section sources**
- [serverV2.py](file://serverV2.py#L1543-L1607)
- [serverV2.py](file://serverV2.py#L1081-L1229)
- [serverV2.py](file://serverV2.py#L1728-L1862)
- [serverV2.py](file://serverV2.py#L1864-L1956)

## 调试建议
- **查看API响应日志**: 服务器使用`logging`模块记录详细日志。在`serverV2.py`的启动脚本中，日志级别设置为`INFO`。检查控制台输出或日志文件，可以获取请求处理的详细流程、错误堆栈和关键信息（如API调用成功/失败）。
- **检查配置文件**: 确保`config.json`中的API Key、模型名称和代理设置正确无误。特别是`models`下的`api_key`和`use_proxy`，以及`general.proxy`的配置。
- **验证文件路径**: 确认`PROJECTS_DIR`、`OUTPUT_DIR`等目录存在且有读写权限。检查上传的文件是否被正确解码为UTF-8。
- **处理编码问题**: `upload_txt_novel`端点会尝试多种编码（utf-8-sig, utf-8, gb18030）来解码上传的TXT文件，若所有尝试失败，则会强制替换未知字符。上传前建议将文件保存为UTF-8编码以避免问题。

**Section sources**
- [serverV2.py](file://serverV2.py#L37-L38)
- [serverV2.py](file://serverV2.py#L1554-L1576)
- [config.json](file://config.json#L1-L45)