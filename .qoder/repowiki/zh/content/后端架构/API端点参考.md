# API端点参考

<cite>
**Referenced Files in This Document**   
- [serverV2.py](file://serverV2.py)
- [config.json](file://config.json)
</cite>

## 目录
1. [简介](#简介)
2. [小说管理API](#小说管理api)
3. [章节处理API](#章节处理api)
4. [角色管理API](#角色管理api)
5. [音色配置API](#音色配置api)
6. [语音生成API](#语音生成api)
7. [音频拼接与特效API](#音频拼接与特效api)
8. [系统配置API](#系统配置api)
9. [有声书生成流程](#有声书生成流程)
10. [安全与错误处理](#安全与错误处理)

## 简介
本API文档详细说明了`serverV2.py`中定义的FastAPI后端服务的所有端点。该服务旨在为AI有声书制作工具提供完整的后端支持，核心功能包括：小说文件上传与管理、章节内容智能处理、角色与音色配置、多模型语音合成（TTS）、音频特效处理、以及最终音频的拼接与导出。API设计遵循RESTful原则，使用JSON进行数据交换，并通过Pydantic模型进行严格的请求和响应数据验证。

**Section sources**
- [serverV2.py](file://serverV2.py#L47-L48)

## 小说管理API
这些端点负责小说项目的创建、查询和删除。

### 上传TXT小说
此端点用于上传一个TXT格式的小说文件，服务器会将其解析、分章，并创建一个新的项目。

- **HTTP方法**: `POST`
- **URL路径**: `/api/upload_txt_novel`
- **请求参数**:
  - `file` (FormData): 要上传的TXT文件。
- **响应格式**:
  ```json
  {
    "status": "success",
    "message": "小说 'xxx' 已成功上传并统一转换为UTF-8。",
    "chapters": [
      {"id": 0, "title": "第一章 东风夜放花千树"},
      {"id": 1, "title": "第二章 月上柳梢头"}
    ]
  }
  ```
- **错误码**:
  - `500 Internal Server Error`: 文件处理失败。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/upload_txt_novel" -H "accept: application/json" -F "file=@/path/to/novel.txt"
  ```
- **使用示例 (JavaScript)**:
  ```javascript
  const formData = new FormData();
  formData.append('file', fileInput.files[0]);
  fetch('/api/upload_txt_novel', { method: 'POST', body: formData })
    .then(response => response.json())
    .then(data => console.log(data));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1543-L1607)

### 列出所有小说
获取所有已上传小说的详细信息列表。

- **HTTP方法**: `GET`
- **URL路径**: `/api/list_novels`
- **响应格式**:
  ```json
  {
    "novels_details": {
      "我的小说": {
        "chapters": [
          {"id": 0, "title": "第一章", "processed": true, "spliced": false},
          {"id": 1, "title": "第二章", "processed": false, "spliced": false}
        ],
        "isTxtProject": true
      }
    }
  }
  ```
- **错误码**: 无特定错误码，返回空对象表示无数据。
- **使用示例 (curl)**:
  ```bash
  curl -X GET "http://localhost:8000/api/list_novels"
  ```
- **使用示例 (JavaScript)**:
  ```javascript
  fetch('/api/list_novels')
    .then(response => response.json())
    .then(data => console.log(data.novels_details));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1610-L1663)

### 删除小说
根据小说名称删除整个项目，包括项目文件和输出的音频。

- **HTTP方法**: `DELETE`
- **URL路径**: `/api/delete_novel?novel_name={novel_name}`
- **请求参数**:
  - `novel_name` (Query): 要删除的小说名称。
- **响应格式**:
  ```json
  {"status": "success", "message": "小说项目 'xxx' 已被永久删除。"}
  ```
- **错误码**:
  - `400 Bad Request`: 小说名称为空。
  - `403 Forbidden`: 小说名称包含非法字符（安全检查）。
  - `404 Not Found`: 小说项目未找到。
  - `500 Internal Server Error`: 删除过程中发生错误。
- **使用示例 (curl)**:
  ```bash
  curl -X DELETE "http://localhost:8000/api/delete_novel?novel_name=我的小说"
  ```
- **使用示例 (JavaScript)**:
  ```javascript
  fetch('/api/delete_novel?novel_name=我的小说', { method: 'DELETE' })
    .then(response => response.json())
    .then(data => console.log(data));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L898-L945)

## 章节处理API
此端点用于处理单个章节，包括内容预览、AI分析和生成。

### 处理单个章节
处理指定小说的指定章节，执行AI分析、角色识别和生成中间JSON文件。

- **HTTP方法**: `POST`
- **URL路径**: `/api/process_single_chapter`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "chapter_title": "string",
    "model_name": "string",
    "force_regenerate": false,
    "preview_only": false
  }
  ```
- **请求模型**: `ProcessSingleChapterRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "章节 'xxx' 处理成功。"}
  ```
  或预览模式：
  ```json
  {"status": "preview", "content": "原始章节文本内容..."}
  ```
- **错误码**:
  - `400 Bad Request`: 缺少必要参数（如`model_name`）。
  - `404 Not Found`: 小说或章节未找到。
  - `500 Internal Server Error`: 处理过程中发生错误。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/process_single_chapter" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"chapter_title\": \"第一章\", \"model_name\": \"gemini\"}"
  ```
- **使用示例 (JavaScript)**:
  ```javascript
  fetch('/api/process_single_chapter', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      novel_name: '我的小说',
      chapter_title: '第一章',
      model_name: 'gemini'
    })
  }).then(response => response.json()).then(data => console.log(data));
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1081-L1229)

## 角色管理API
这些端点用于合并角色和深度分析角色信息。

### 合并角色
将一个或多个源角色合并到一个目标角色下。如果音色相同，会自动重命名对应的WAV文件。

- **HTTP方法**: `POST`
- **URL路径**: `/api/merge_characters`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "target_name": "string",
    "source_names": ["string"],
    "chapter_files": ["string"]
  }
  ```
- **请求模型**: `MergeCharactersRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "成功合并角色。X个音频文件被自动重命名，无需重新生成。"}
  ```
- **错误码**:
  - `400 Bad Request`: 请求参数不完整或目标名称在源名称列表中。
  - `500 Internal Server Error`: 服务器处理时发生错误。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/merge_characters" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"target_name\": \"张三\", \"source_names\": [\"张三丰\"], \"chapter_files\": [\"第一章.json\"]}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L358-L478)

### 深度分析角色
使用LLM模型聚合角色在所有章节中的对话，以补全其性别、年龄段和身份等简介信息。

- **HTTP方法**: `POST`
- **URL路径**: `/api/deep_analyze_character`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "character_name": "string",
    "model_name": "string"
  }
  ```
- **请求模型**: `DeepAnalyzeRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "角色「xxx」的信息已成功补全！", "data": {"gender": "男", "ageGroup": "青年", "identity": "主角，性格坚毅..."}}
  ```
- **错误码**:
  - `404 Not Found`: 角色或其简介文件未找到。
  - `500 Internal Server Error`: 分析过程中发生错误。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/deep_analyze_character" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"character_name\": \"张三\", \"model_name\": \"gemini\"}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L767-L813)

## 音色配置API
这些端点用于获取和更新小说的音色配置。

### 获取音色配置
获取指定小说的角色音色映射配置。

- **HTTP方法**: `GET`
- **URL路径**: `/api/get_config?novel_name={novel_name}`
- **请求参数**:
  - `novel_name` (Query): 小说名称。
- **响应格式**: 返回`character_timbres.json`文件的内容，例如：
  ```json
  {"张三": "男声-沉稳", "李四": "男声-活泼"}
  ```
  如果文件不存在，则返回空JSON对象`{}`。
- **错误码**:
  - `404 Not Found`: 小说项目未找到。
- **使用示例 (curl)**:
  ```bash
  curl -X GET "http://localhost:8000/api/get_config?novel_name=我的小说"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1708-L1712)

### 更新音色配置
更新指定小说的角色音色映射配置。

- **HTTP方法**: `POST`
- **URL路径**: `/api/update_config`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "config_data": {"string": "string"}
  }
  ```
- **请求模型**: `UpdateConfigRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "小说 'xxx' 的音色配置已保存。"}
  ```
- **错误码**:
  - `404 Not Found`: 小说项目未找到。
  - `500 Internal Server Error`: 写入文件失败。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/update_config" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"config_data\": {\"张三\": \"男声-沉稳\"}}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1715-L1725)

## 语音生成API
此端点用于调用TTS微服务生成单句语音。

### TTS语音生成 (v2)
根据提供的文本、参考音频和音色，生成高质量的语音WAV文件。

- **HTTP方法**: `POST`
- **URL路径**: `/api/tts_v2`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "chapter_name": "string",
    "row_index": 0,
    "speaker": "string",
    "timbre": "string",
    "tts_text": "string",
    "prompt_audio": "base64_string",
    "prompt_text": "string",
    "inference_mode": "string",
    "instruct_text": "string",
    "tts_model": "string"
  }
  ```
- **请求模型**: `TTSRequestV2`
- **响应格式**:
  ```json
  {"status": "success", "file_name": "0000-张三-男声-沉稳.wav"}
  ```
- **错误码**:
  - `400 Bad Request`: TTS模型配置无效。
  - `500 Internal Server Error`: TTS生成失败。
  - `503 Service Unavailable`: 无法连接到TTS微服务。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/tts_v2" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"chapter_name\": \"第一章\", \"row_index\": 0, \"speaker\": \"张三\", \"timbre\": \"男声-沉稳\", \"tts_text\": \"你好世界\", \"prompt_audio\": \"base64data...\", \"prompt_text\": \"你好\", \"inference_mode\": \"i\", \"tts_model\": \"cosyvoice_v2\"}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1728-L1862)

## 音频拼接与特效API
这些端点用于拼接音频、应用特效和生成合声。

### 拼接音频
将一个章节中所有生成的单句WAV文件按顺序拼接成一个完整的音频文件。

- **HTTP方法**: `POST`
- **URL路径**: `/api/splice_audio`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "chapter_name": "string"
  }
  ```
- **请求模型**: `SpliceRequest`
- **响应格式**:
  ```json
  {"status": "success", "file_path": "/output/我的小说/第一章.mp3"}
  ```
- **错误码**:
  - `400 Bad Request`: 没有找到可拼接的文件。
  - `404 Not Found`: 章节JSON文件不存在。
  - `500 Internal Server Error`: 拼接过程中发生错误。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/splice_audio" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"chapter_name\": \"第一章\"}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1864-L1956)

### 应用音频特效
对已生成的单句WAV文件应用手机通话、喇叭喊话或室内回声等特效。

- **HTTP方法**: `POST`
- **URL路径**: `/api/apply_effect`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "chapter_name": "string",
    "file_name": "string",
    "effect_type": "phone|megaphone|reverb"
  }
  ```
- **请求模型**: `EffectRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "'手机通话' 特效已应用。"}
  ```
- **错误码**:
  - `400 Bad Request`: 未知的特效类型。
  - `404 Not Found`: 音频文件未找到。
  - `500 Internal Server Error`: 处理特效失败。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/apply_effect" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"chapter_name\": \"第一章\", \"file_name\": \"0000-张三-男声-沉稳.wav\", \"effect_type\": \"phone\"}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1376-L1433)

### 生成合声效果
为同一段文本生成多个音色的语音，并将它们混合成一个“多人同声”的效果。

- **HTTP方法**: `POST`
- **URL路径**: `/api/generate_choral_effect`
- **请求体 (JSON)**:
  ```json
  {
    "novel_name": "string",
    "chapter_name": "string",
    "row_index": 0,
    "tts_text": "string",
    "selected_timbres": ["string"],
    "original_speaker": "string",
    "original_timbre": "string",
    "tts_model": "string"
  }
  ```
- **请求模型**: `ChoralRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "多人同声效果生成成功！", "file_name": "0000-张三-男声-沉稳.wav"}
  ```
- **错误码**:
  - `400 Bad Request`: 选择的音色少于两个。
  - `500 Internal Server Error`: 生成或混合过程中发生错误。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/generate_choral_effect" -H "Content-Type: application/json" -d "{\"novel_name\": \"我的小说\", \"chapter_name\": \"第一章\", \"row_index\": 0, \"tts_text\": \"大家好！\", \"selected_timbres\": [\"男声-沉稳\", \"女声-活泼\"], \"original_speaker\": \"张三\", \"original_timbre\": \"男声-沉稳\"}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L1446-L1536)

## 系统配置API
这些端点用于获取和更新全局的LLM模型配置。

### 获取LLM配置
获取全局的LLM模型配置文件（`config.json`）。

- **HTTP方法**: `GET`
- **URL路径**: `/api/get_llm_config`
- **响应格式**: 返回`config.json`文件的完整内容。
- **错误码**:
  - `404 Not Found`: LLM配置文件未找到。
- **使用示例 (curl)**:
  ```bash
  curl -X GET "http://localhost:8000/api/get_llm_config"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L247-L250)

### 更新LLM配置
更新全局的LLM模型配置文件。

- **HTTP方法**: `POST`
- **URL路径**: `/api/update_llm_config`
- **请求体 (JSON)**:
  ```json
  {"config": { /* config.json 的完整内容 */ }}
  ```
- **请求模型**: `LLMConfigRequest`
- **响应格式**:
  ```json
  {"status": "success", "message": "模型配置已成功保存。"}
  ```
- **错误码**:
  - `500 Internal Server Error`: 写入配置文件失败。
- **使用示例 (curl)**:
  ```bash
  curl -X POST "http://localhost:8000/api/update_llm_config" -H "Content-Type: application/json" -d "{\"config\": {\"general\": {\"default_model\": \"gemini\"}, \"models\": {\"gemini\": {\"api_key\": \"your_key\"}}}}"
  ```

**Section sources**
- [serverV2.py](file://serverV2.py#L256-L262)

## 有声书生成流程
前端应用通常通过组合调用多个API来完成有声书的生成。一个典型的流程如下：

1.  **上传小说**: 调用`/api/upload_txt_novel`上传TXT文件。
2.  **获取章节列表**: 调用`/api/list_novels`获取所有章节。
3.  **处理章节**: 对每个章节调用`/api/process_single_chapter`，生成JSON结构。
4.  **配置音色**: 用户在前端配置角色音色，然后调用`/api/update_config`保存。
5.  **生成语音**: 遍历JSON中的每一行，调用`/api/tts_v2`生成单句WAV。
6.  **应用特效**: （可选）对特定句子调用`/api/apply_effect`。
7.  **拼接音频**: 调用`/api/splice_audio`将单句拼接成完整章节音频。
8.  **导出**: 前端通过`/output/`路径访问生成的音频文件。

**Section sources**
- [serverV2.py](file://serverV2.py#L48)

## 安全与错误处理
本API在设计时考虑了安全性与健壮性：

- **输入验证**: 所有请求体都通过Pydantic模型进行验证，确保数据类型和必填字段。
- **异常处理**: 使用`try-except`块捕获内部错误，并通过`HTTPException`返回清晰的错误信息。
- **安全检查**:
  - `delete_novel`和`get_novel_content`等端点包含目录遍历攻击防护，确保路径在合法目录内。
  - 文件路径使用`os.path.join`和`os.path.abspath`进行安全构建。
- **CORS配置**: 通过`CORSMiddleware`允许所有来源的跨域请求，方便前端开发。
- **日志记录**: 使用`logging`模块记录关键操作和错误，便于调试。

**Section sources**
- [serverV2.py](file://serverV2.py#L48)
- [serverV2.py](file://serverV2.py#L898-L945)
- [serverV2.py](file://serverV2.py#L864-L895)