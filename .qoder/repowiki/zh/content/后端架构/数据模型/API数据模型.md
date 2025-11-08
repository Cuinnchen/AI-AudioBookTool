# API数据模型

<cite>
**Referenced Files in This Document**   
- [serverV2.py](file://serverV2.py)
</cite>

## 目录
1. [引言](#引言)
2. [核心请求模型详解](#核心请求模型详解)
3. [请求数据验证机制](#请求数据验证机制)
4. [序列化与反序列化示例](#序列化与反序列化示例)
5. [模型扩展性设计](#模型扩展性设计)
6. [常见错误与解决方案](#常见错误与解决方案)

## 引言

本文档旨在深入解析 `serverV2.py` 文件中定义的 Pydantic 请求与响应模型。这些模型是 AI 有声书工具后端服务的核心，它们为 FastAPI 接口提供了严格的结构化数据定义，确保了前后端通信的健壮性和一致性。通过详细分析 `TTSRequestV2`、`SpliceRequest`、`MergeCharactersRequest`、`DeepAnalyzeRequest` 和 `UpdateConfigRequest` 等关键模型，我们将揭示其字段含义、数据类型、验证规则以及在系统中的业务用途。

**Section sources**
- [serverV2.py](file://serverV2.py#L57-L150)

## 核心请求模型详解

### TTSRequestV2 模型

`TTSRequestV2` 模型用于定义文本转语音（TTS）任务的请求体，是生成单句音频的核心数据结构。

**字段说明**:
- `novel_name`: (str) 小说项目的名称，用于定位项目目录。
- `chapter_name`: (str) 当前处理的章节名称。
- `row_index`: (int) 该文本在章节中的行索引，用于生成唯一文件名。
- `speaker`: (str) 说话者的角色名称。
- `timbre`: (str) 使用的音色名称。
- `tts_text`: (str) 需要转换为语音的原始文本内容。
- `prompt_audio`: (str) 参考音频的 Base64 编码字符串。
- `prompt_text`: (str) 参考音频对应的文本。
- `inference_mode`: (str) TTS 模型的推理模式（如“音色克隆”）。
- `instruct_text`: (Optional[str]) 指令文本，用于指导语音生成，为可选字段。
- `tts_model`: (Optional[str]) 指定使用的 TTS 模型ID，为可选字段，允许系统使用默认模型。

该模型通过 `tts_model` 和 `instruct_text` 的可选性，为未来功能迭代提供了良好的扩展基础。

**Section sources**
- [serverV2.py](file://serverV2.py#L74-L78)

### SpliceRequest 模型

`SpliceRequest` 模型用于请求将单句音频拼接成完整章节音频。

**字段说明**:
- `novel_name`: (str) 小说项目的名称。
- `chapter_name`: (str) 需要拼接的章节名称。
- `wav_files`: (List[str]) 需要拼接的音频文件名列表。此字段在当前实现中虽被定义，但实际拼接逻辑由后端根据章节JSON文件自动生成，体现了前后端逻辑的解耦。

**Section sources**
- [serverV2.py](file://serverV2.py#L80-L81)

### MergeCharactersRequest 模型

`MergeCharactersRequest` 模型用于合并小说中的角色信息。

**字段说明**:
- `novel_name`: (str) 小说项目的名称。
- `target_name`: (str) 目标角色的名称，所有源角色将被合并到此角色下。
- `source_names`: (List[str]) 需要被合并的源角色名称列表。
- `chapter_files`: (List[str]) 需要处理的章节文件列表。

此模型的业务逻辑不仅修改章节JSON中的角色名，还会智能地重命名已生成的音频文件（当音色相同时），避免了不必要的重复生成。

**Section sources**
- [serverV2.py](file://serverV2.py#L59-L63)

### DeepAnalyzeRequest 模型

`DeepAnalyzeRequest` 模型用于对角色进行深度分析，以补全其人物简介。

**字段说明**:
- `novel_name`: (str) 小说项目的名称。
- `character_name`: (str) 需要分析的角色名称。
- `model_name`: (str) 用于分析的AI大模型名称（如 "gemini"）。

该模型通过调用大模型，聚合角色在所有章节中的对话内容，从而推断出其性别、年龄段和身份背景等信息。

**Section sources**
- [serverV2.py](file://serverV2.py#L124-L127)

### UpdateConfigRequest 模型

`UpdateConfigRequest` 模型用于更新小说项目的配置信息。

**字段说明**:
- `novel_name`: (str) 小说项目的名称。
- `config_data`: (dict) 包含配置数据的字典，通常用于存储角色与音色的映射关系。

该模型的 `config_data` 字段是一个灵活的字典，可以容纳任意结构的配置信息，为系统的配置管理提供了极大的灵活性。

**Section sources**
- [serverV2.py](file://serverV2.py#L86-L87)

## 请求数据验证机制

FastAPI 与 Pydantic 的结合为 API 提供了强大的自动请求数据验证能力。当客户端发起请求时，FastAPI 会自动将请求体中的 JSON 数据反序列化为对应的 Pydantic 模型实例。

**验证流程**:
1.  **类型检查**: Pydantic 会检查每个字段的数据类型是否匹配。例如，`row_index` 必须是整数，`speaker` 必须是字符串。
2.  **必填项验证**: 所有未标记为 `Optional` 的字段都是必填的。如果缺少 `novel_name` 或 `tts_text` 等字段，FastAPI 会立即返回 422 Unprocessable Entity 错误。
3.  **错误反馈**: 验证失败时，FastAPI 会返回一个详细的 JSON 错误响应，明确指出是哪个字段、何种原因导致验证失败，极大地便利了前端调试。

这种机制确保了后端接收到的数据始终是结构正确且类型安全的，有效防止了因无效数据导致的运行时错误。

**Section sources**
- [serverV2.py](file://serverV2.py#L1-L48)
- [serverV2.py](file://serverV2.py#L1728-L1862)

## 序列化与反序列化示例

### 客户端请求示例 (TTSRequestV2)

以下是一个客户端构造 `TTSRequestV2` 请求体的 JSON 示例：

```json
{
  "novel_name": "红楼梦",
  "chapter_name": "第001章 甄士隐梦幻识通灵",
  "row_index": 15,
  "speaker": "贾宝玉",
  "timbre": "青年男声-温柔",
  "tts_text": "女儿是水做的骨肉，男人是泥做的骨肉。",
  "prompt_audio": "base64_encoded_audio_string...",
  "prompt_text": "这女儿两个字，极尊贵，极清净的。",
  "inference_mode": "clone",
  "instruct_text": "用天真烂漫的语气朗读",
  "tts_model": "cosyvoice_v2"
}
```

### 服务端处理流程
1.  **反序列化**: FastAPI 接收到此 JSON 后，会自动调用 `TTSRequestV2` 模型的 `__init__` 方法，将 JSON 数据转换为一个 `TTSRequestV2` 对象。
2.  **验证**: 在转换过程中，Pydantic 会验证所有字段。如果 `row_index` 是字符串 "15"，它会被自动转换为整数；如果 `instruct_text` 字段缺失，由于其是 `Optional`，验证依然通过。
3.  **序列化**: 当服务端处理完成后，会将结果（如 `{"status": "success", "file_name": "0015-贾宝玉-青年男声-温柔.wav"}`）序列化为 JSON 并返回给客户端。

**Section sources**
- [serverV2.py](file://serverV2.py#L1844-L1862)
- [serverV2.py](file://serverV2.py#L1468-L1498)

## 模型扩展性设计

该系统的 Pydantic 模型设计充分考虑了未来的扩展性，主要体现在以下几个方面：

1.  **可选字段 (`Optional`)**: 通过将 `instruct_text` 和 `tts_model` 等字段定义为 `Optional[str]`，系统可以在不破坏现有 API 兼容性的情况下，逐步引入新功能。旧版本的客户端可以继续发送不包含这些字段的请求，而新版本的客户端则可以利用这些字段实现更高级的功能。
2.  **灵活的数据结构**: `UpdateConfigRequest` 模型使用 `dict` 类型的 `config_data` 字段，使其能够存储任意结构的配置信息。未来可以轻松地向配置中添加新的键值对，而无需修改模型定义。
3.  **模块化设计**: 每个 API 端点都有其专用的请求模型，职责单一。当需要为某个功能添加新参数时，只需修改对应的模型，不会影响到其他不相关的接口。

这种设计模式遵循了开闭原则（对扩展开放，对修改关闭），使得系统能够灵活地适应不断变化的需求。

**Section sources**
- [serverV2.py](file://serverV2.py#L74-L78)
- [serverV2.py](file://serverV2.py#L86-L87)

## 常见错误与解决方案

### 常见错误
1.  **缺少必填字段**: 请求体中遗漏了 `novel_name`、`tts_text` 等非可选字段。
2.  **数据类型错误**: 例如，将 `row_index` 的值写成字符串 `"15"`（虽然 Pydantic 会尝试转换，但某些类型如布尔值与字符串的转换会失败）。
3.  **字段名拼写错误**: 如将 `tts_text` 误写为 `ttstext`，这将导致该字段被忽略，可能引发后续逻辑错误。
4.  **JSON 格式错误**: 发送的请求体不是有效的 JSON 格式。

### 解决方案
1.  **仔细核对文档**: 在构造请求体前，务必参考本文档中各模型的字段定义。
2.  **使用代码生成工具**: 在前端开发中，可以使用 OpenAPI/Swagger 生成的客户端代码，这能从根本上避免拼写和类型错误。
3.  **利用开发工具**: 使用 Postman 或 curl 等工具进行测试，并仔细阅读 FastAPI 返回的 422 错误响应，它会精确指出问题所在。
4.  **确保 JSON 有效性**: 在发送请求前，使用在线 JSON 验证器检查请求体的格式。

通过遵循这些最佳实践，可以确保与后端 API 的通信高效且无误。

**Section sources**
- [serverV2.py](file://serverV2.py#L1728-L1862)