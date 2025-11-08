# API客户端

<cite>
**Referenced Files in This Document**   
- [index.html](file://index.html)
</cite>

## 目录
1. [简介](#简介)
2. [API客户端实现](#api客户端实现)
3. [关键API端点调用](#关键api端点调用)
4. [异步操作管理](#异步操作管理)
5. [响应处理逻辑](#响应处理逻辑)
6. [批量处理与音频拼接](#批量处理与音频拼接)

## 简介
本项目是一个AI语音工作室的前端应用，通过JavaScript的fetch函数与后端FastAPI服务进行通信。该应用允许用户上传小说文本，处理章节，为角色分配音色，并生成语音。前端通过调用一系列API端点来实现这些功能，包括上传小说、处理章节、生成语音等。

## API客户端实现
前端通过`fetchFromServer`函数封装了与后端的通信。该函数使用`fetch` API发送HTTP请求，并处理响应。请求的构建过程包括设置HTTP方法、请求头（如`Content-Type`）和请求体（JSON序列化）。例如，在上传小说时，前端会创建一个`FormData`对象，将文件添加到其中，然后通过POST请求发送到`/api/upload_txt_novel`端点。

```javascript
async function fetchFromServer(url, options = {}) {
    const response = await fetch(url, options);
    if (!response.ok) {
        const errorData = await response.json().catch(() => ({ detail: response.statusText }));
        throw new Error(errorData.detail || `请求失败: ${response.status}`);
    }
    return response.json();
}
```

**Section sources**
- [index.html](file://index.html#L1027-L1034)

## 关键API端点调用
前端调用了多个关键API端点来实现其功能。例如，`/api/upload_txt_novel`用于上传小说文本，`/api/process_single_chapter`用于处理单个章节，`/api/tts_v2`用于生成语音。这些端点的调用方式如下：

- **上传小说**: 使用`FormData`对象将文件发送到`/api/upload_txt_novel`。
- **处理章节**: 发送包含章节信息的JSON数据到`/api/process_single_chapter`。
- **生成语音**: 发送包含语音生成参数的JSON数据到`/api/tts_v2`。

```javascript
const newProjectData = await fetchFromServer('/api/upload_txt_novel', { 
    method: 'POST', 
    body: formData 
});
```

**Section sources**
- [index.html](file://index.html#L1277-L1281)
- [index.html](file://index.html#L1470-L1475)
- [index.html](file://index.html#L2047-L2052)

## 异步操作管理
前端使用`async/await`语法来管理异步操作的时序。这使得代码更加清晰易读，避免了回调地狱。例如，在处理所有章节并拼接音频时，前端会依次调用多个API端点，并等待每个请求完成后再进行下一步操作。

```javascript
async function processAllAndSplice() {
    // ...
    for (const chapterPath of chaptersToProcess) {
        // ...
        const chapterData = await fetchFromServer(`/api/get_novel_content?filepath=${encodeURIComponent(chapterPath)}`);
        // ...
    }
    // ...
}
```

**Section sources**
- [index.html](file://index.html#L2079-L2227)

## 响应处理逻辑
前端通过解析JSON响应来处理成功与错误状态。如果响应状态码不是2xx，前端会抛出一个错误，并显示错误消息。否则，前端会解析响应体中的JSON数据，并根据结果更新UI或显示成功消息。

```javascript
if (!response.ok) {
    const errorData = await response.json().catch(() => ({ detail: response.statusText }));
    throw new Error(errorData.detail || `请求失败: ${response.status}`);
}
return response.json();
```

**Section sources**
- [index.html](file://index.html#L1029-L1033)

## 批量处理与音频拼接
`processAllAndSplice`函数展示了如何批量调用API生成语音并拼接音频。该函数首先加载所有选中的章节，然后逐个处理每个章节的每一行内容，生成语音文件。最后，它会调用`/api/splice_audio`端点将所有生成的音频文件拼接成一个完整的音频文件。

```javascript
const result = await fetchFromServer('/api/splice_audio', { 
    method: 'POST', 
    headers: { 'Content-Type': 'application/json' }, 
    body: JSON.stringify(splicePayload) 
});
```

**Section sources**
- [index.html](file://index.html#L2187-L2188)