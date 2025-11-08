# UI组件

<cite>
**本文档引用的文件**   
- [index.html](file://index.html)
- [style.css](file://style.css)
</cite>

## 目录
1. [项目结构](#项目结构)
2. [核心UI组件](#核心ui组件)
3. [视觉样式与主题化设计](#视觉样式与主题化设计)
4. [交互行为与动态操作](#交互行为与动态操作)
5. [模态框（Modal）逻辑](#模态框modal逻辑)
6. [滚动容器布局](#滚动容器布局)

## 项目结构
本项目是一个用于AI有声书制作的前端应用，其核心文件包括`index.html`、`style.css`和`serverV2.py`。`index.html`定义了整个用户界面的四大功能区域：小说管理与处理、角色-音色配置、音色库管理以及内容编辑器。`style.css`文件则负责全局的视觉样式和布局，通过CSS变量实现了主题化设计。`serverV2.py`作为后端服务，为前端提供API接口。用户通过`启动ServerV2.bat`批处理文件来启动服务器。

**Section sources**
- [index.html](file://index.html#L1-L4203)
- [style.css](file://style.css#L1-L190)

## 核心UI组件
前端用户界面由`index.html`文件构建，采用四列布局（`spa-layout`），清晰地划分了四大功能区域。

### 小说管理与处理面板
该面板位于第一列，是用户工作的起点。其核心组件包括：
*   **模型选择下拉框 (`#llmModelSelector`)**：允许用户选择用于处理文本的AI模型。
*   **上传按钮 (`#uploadTxtLabelBtn`)**：触发文件选择，用于上传新的小说文本文件。
*   **小说选择下拉框 (`#novelSelector`)**：列出所有已加载的小说项目，用户可从中选择。
*   **删除按钮 (`#deleteNovelBtn`)**：用于删除当前选中的小说项目。
*   **章节列表 (`#chapter-list`)**：一个可滚动的列表，显示所选小说的所有章节。列表项通过`<li>`元素实现，支持复选框进行多选，并通过`processed`和`spliced` CSS类来显示章节的处理状态（已处理、已拼接）。
*   **控制按钮**：包括“全选”、“全不选”和“过滤”按钮，用于批量操作和筛选章节。

### 角色-音色配置区
该区域位于第二列，用于管理角色与音色的映射关系。
*   **角色列表 (`#character-list`)**：一个可滚动的列表，显示当前选中章节中出现的所有角色。每个角色项包含角色名、已分配的音色名以及“试听”和“简介”按钮。
*   **操作按钮**：包括“角色名管理”、“管理替换词典”和“保存当前配置”按钮，用于高级配置和持久化。

### 音色库管理区
该区域位于第三列，用于管理和使用音色。
*   **分类筛选下拉框 (`#categoryFilter`)**：允许用户按分类筛选音色。
*   **音色列表 (`#timbre-list`)**：一个可滚动的列表，显示所有可用的音色。每个音色项包含音色名、“分配”按钮和“试听”按钮。
*   **操作按钮**：包括“管理音色库”和“上传新音色”按钮，用于音色库的维护。

### 内容编辑器
该区域位于第四列，是核心的编辑工作区。
*   **表格化内容展示 (`#content-table`)**：以表格形式展示已处理章节的对话内容。表格包含操作列、序号、角色、音色（下拉框）、内容（可编辑）、TTS模型和操作列。
*   **操作按钮**：包括“添加新行到首行”和“保存对本章节的修改”按钮，用于编辑和持久化内容。

**Section sources**
- [index.html](file://index.html#L401-L525)

## 视觉样式与主题化设计
`style.css`文件通过定义CSS变量和核心样式类，实现了统一且可定制的视觉风格。

### CSS变量与主题化
文件在`:root`伪类中定义了一系列CSS变量，这些变量是实现主题化设计的基础。
*   **颜色变量**：`--primary-color`（主色调）、`--bg-color`（背景色）、`--surface-color`（表面色）、`--text-color-primary`（主文本色）、`--border-color`（边框色）等，确保了颜色的一致性。
*   **尺寸与圆角**：`--border-radius`（边框圆角）和`--font-family`（字体）等变量，统一了UI元素的外观。
*   **状态颜色**：`--selection-color`（选中状态背景色）、`--highlight-color`（高亮色）等，用于反馈用户交互。

通过修改这些变量的值，可以轻松地改变整个应用的主题，而无需修改具体的样式规则。

### 核心样式类应用
*   **`.info-list`**：这是一个基础的列表样式类，用于`#chapter-list`、`#character-list`和`#timbre-list`。它移除了默认的列表样式（`list-style: none`），并为列表项（`li`）设置了统一的内边距、边框和过渡效果，确保了列表的整洁和一致性。
*   **`.btn`**：这是所有按钮的基础样式类。它定义了按钮的内边距、边框、圆角、背景色、文字颜色、光标样式和过渡效果。通过`btn-primary`、`btn-danger`等修饰类，可以快速创建不同状态的按钮。按钮的禁用状态通过`:disabled`伪类实现，改变了背景色、边框色和文字颜色。
*   **`.scrollable-content`**：这是一个关键的布局类，应用于所有需要滚动的容器（如`#col1-content-wrapper`、`#chapter-list-wrapper`等）。它通过`flex-grow: 1`和`overflow-y: auto`，使容器能够填充剩余空间并实现垂直滚动，是实现自适应布局的核心。

**Section sources**
- [style.css](file://style.css#L2-L130)

## 交互行为与动态操作
UI的交互行为由`index.html`中的JavaScript代码驱动，实现了丰富的动态效果。

### 按钮状态
*   **普通状态**：按钮具有统一的背景色、边框和文字颜色。
*   **悬停状态**：通过`:hover:not(:disabled)`选择器实现，当鼠标悬停时，背景色会变浅（`btn:hover`）或变为特定的悬停色（`btn-primary:hover`），提供视觉反馈。
*   **禁用状态**：通过`:disabled`选择器实现，禁用的按钮背景色和文字色会变灰，光标变为`not-allowed`，明确告知用户该操作不可用。

### 动态DOM操作
JavaScript通过操作DOM元素来更新UI。例如：
*   **更新章节列表**：`renderChapterList()`函数会根据当前状态，动态地清空`#chapter-list`并重新填充`<li>`元素，显示最新的章节信息。
*   **更新角色配置**：当用户为角色分配音色时，`state.characterMapping`对象会被更新，随后调用`loadCharacters()`和`renderContentTable()`来刷新角色列表和内容编辑器表格，反映最新的配置。

**Section sources**
- [index.html](file://index.html#L806-L4155)

## 模态框（Modal）逻辑
应用中使用了多个模态框（Modal）来处理复杂的用户交互，如上传音色、全局设置和删除确认。

### 显示与关闭逻辑
*   **显示**：通过将模态框外层容器（如`#timbreUploadModal`）的`display`属性从`none`改为`flex`来显示模态框。
*   **关闭**：提供了多种关闭方式：
    1.  **点击关闭按钮**：如`#cancelUploadBtn`，点击后执行`hideTimbreUploadModal()`函数。
    2.  **点击遮罩层**：为模态框外层容器（`#timbreUploadModal`）添加点击事件监听器，当点击事件的目标是容器本身时，关闭模态框。
    3.  **键盘事件**：部分模态框支持按`Enter`键确认，按`Escape`键取消。

### 事件监听器
每个模态框都绑定了相应的事件监听器。例如，`#confirmUploadBtn`的点击事件会触发`handleTimbreUpload()`函数，处理上传逻辑。这些监听器在模态框初始化时被添加，确保了交互的响应性。

**Section sources**
- [index.html](file://index.html#L529-L772)

## 滚动容器布局
滚动容器的布局机制是通过CSS的Flexbox模型和`overflow`属性实现的。

### 布局机制
以小说管理面板为例，其结构如下：
```html
<div class="content-column"> <!-- 外层容器，flex-direction: column -->
    <h2 class="column-header">...</h2> <!-- 固定头部 -->
    <div id="col1-content-wrapper" class="scrollable-content"> <!-- 可滚动区域 -->
        <div class="chapter-controls">...</div> <!-- 固定控制条 -->
        <div id="chapter-list-wrapper"> <!-- 真正的滚动容器 -->
            <ul id="chapter-list" class="info-list">...</ul>
        </div>
    </div>
    <div class="column-footer">...</div> <!-- 固定底部 -->
</div>
```
*   **外层容器 (`content-column`)**：设置为`flex-direction: column`，使其子元素垂直排列。
*   **可滚动区域 (`scrollable-content`)**：通过`flex-grow: 1`占据剩余空间，并通过`overflow-y: auto`实现滚动。
*   **内部结构**：`#chapter-list-wrapper`的`flex-grow: 1`和`overflow-y: auto`确保了`#chapter-list`的内容可以滚动，而`chapter-controls`作为固定控制条不会滚动。

这种嵌套的Flexbox布局确保了头部、控制条和底部固定，只有中间的内容区域可以滚动，提供了良好的用户体验。

**Section sources**
- [index.html](file://index.html#L429-L448)
- [style.css](file://style.css#L85-L104)