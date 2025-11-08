# 章节JSON模型

<cite>
**本文档引用的文件**   
- [serverV2.py](file://serverV2.py)
</cite>

## 目录
1. [章节JSON数据模型](#章节json数据模型)
2. [生成过程](#生成过程)
3. [JSON Schema定义](#json-schema定义)
4. [样本数据示例](#样本数据示例)
5. [语音生成流程](#语音生成流程)
6. [数据验证方法](#数据验证方法)

## 章节JSON数据模型

章节JSON数据模型是一个由LLM分析小说文本后生成的数组结构，用于驱动TTS语音合成。该数组的每个元素代表一个对话条目，包含以下字段：
- **speaker**：说话者名称，字符串类型。
- **content**：对话内容，字符串类型。
- **tone**：语气描述，如“愤怒”、“悲伤”，可选字段。
- **intensity**：情感强度，数值范围1-10，默认值为5。
- **delay**：播放延迟毫秒数，控制语句间隔，默认值为500。

**Section sources**
- [serverV2.py](file://serverV2.py#L153-L185)

## 生成过程

章节JSON数据模型的生成过程如下：
1. 前端调用`/api/process_single_chapter`触发后端处理。
2. 后端调用LLM，LLM根据`PROMPT_TEMPLATE`提示词模板将文本分割为带角色标注的JSON结构。
3. `analyze_character`函数用于分析角色特征，确保生成的JSON结构准确。

**Section sources**
- [serverV2.py](file://serverV2.py#L153-L185)
- [serverV2.py](file://serverV2.py#L595-L679)

## JSON Schema定义

以下是章节JSON数据模型的JSON Schema定义：

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "speaker": {
        "type": "string",
        "description": "说话者姓名"
      },
      "content": {
        "type": "string",
        "description": "对话或旁白内容"
      },
      "tone": {
        "type": "string",
        "description": "语气描述"
      },
      "intensity": {
        "type": "integer",
        "minimum": 1,
        "maximum": 10,
        "default": 5,
        "description": "语气强度"
      },
      "delay": {
        "type": "integer",
        "default": 500,
        "description": "与上一句话之间的停顿时间（毫秒）"
      }
    },
    "required": ["speaker", "content", "tone", "intensity", "delay"]
  }
}
```

**Section sources**
- [serverV2.py](file://serverV2.py#L153-L185)

## 样本数据示例

以下是一个符合章节JSON数据模型的样本数据示例：

```json
[
  {
    "speaker": "旁白",
    "content": "这是一个示例章节。",
    "tone": "正常",
    "intensity": 5,
    "delay": 500
  },
  {
    "speaker": "张三",
    "content": "你好，李四。",
    "tone": "开心",
    "intensity": 7,
    "delay": 300
  }
]
```

**Section sources**
- [serverV2.py](file://serverV2.py#L153-L185)

## 语音生成流程

在语音生成流程中，`tts_v2`接口会逐条处理章节JSON数据模型中的每个对话条目。具体步骤如下：
1. 读取JSON数组中的每个条目。
2. 根据`speaker`字段选择相应的音色。
3. 根据`tone`和`intensity`字段调整语音的语气和强度。
4. 根据`delay`字段控制语句之间的间隔。
5. 生成并拼接最终的音频文件。

**Section sources**
- [serverV2.py](file://serverV2.py#L1728-L1855)

## 数据验证方法

为开发者提供数据验证方法建议，如使用Pydantic模型进行反序列化校验。通过定义Pydantic模型，可以确保传入的数据符合预期的结构和类型，从而提高系统的稳定性和可靠性。

**Section sources**
- [serverV2.py](file://serverV2.py#L56-L93)
- [serverV2.py](file://serverV2.py#L1728-L1855)