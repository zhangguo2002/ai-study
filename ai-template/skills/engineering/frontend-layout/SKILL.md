---
name: frontend-layout
description: Web Demo、管理面板、数据看板的前端布局技能，覆盖导航栏 Tab 溢出处理与瀑布流卡片布局。当用户需要构建含导航栏和卡片的前端页面时使用。
---

# 前端布局技能

> 适用场景：Web Demo、管理面板、数据看板等需要导航栏 + 卡片式内容展示的前端页面。

---

## 一、导航栏（多 Tab 溢出型）

当 Tab 数量不确定且可能超出一行时，**必须**使用「裁剪 + 展开按钮」方案，**禁止**使用 `overflow-x: auto` 横向滚动条。

**结构**：外层 wrapper（flex）= 内层 tab-list（flex: 1, 可溢出裁剪）+ 固定展开按钮（flex-shrink: 0, 始终可见）。

```html
<div class="tab-wrapper">
  <div class="tab-list" id="tabList"><!-- JS 动态填充 tab 按钮 --></div>
  <button class="tab-expand-btn" id="tabExpandBtn">展开 ▼</button>
</div>
```

**CSS 要点**：

```css
.tab-wrapper { display: flex; align-items: flex-start; }
.tab-list {
  display: flex; flex: 1; min-width: 0;
  overflow: hidden;          /* 裁剪，不是 auto/scroll */
  flex-wrap: nowrap;
  max-height: 44px;          /* 单行高度，限制折叠态 */
  transition: max-height .25s ease;
}
.tab-list.expanded {
  flex-wrap: wrap;
  max-height: 600px;         /* 足够大即可 */
  overflow-y: auto;          /* ⚠️ 必须 auto 不是 visible，防止超出 max-height 后覆盖下方内容 */
}
.tab-btn {
  flex-shrink: 0;            /* ⚠️ 必须不可收缩，否则大量 Tab 会被压缩成不可读窄条 */
  white-space: nowrap;       /* 防止按钮文字换行 */
}
.tab-expand-btn { flex-shrink: 0; /* 始终可见于右侧 */ }
```

**JS 要点**：

```js
let expanded = false;
expandBtn.onclick = () => {
  expanded = !expanded;
  tabList.classList.toggle('expanded', expanded);
  expandBtn.textContent = expanded ? '收起 ▲' : '展开 ▼';
};
```

**关键规则**：
- **Tab 按钮三件套**：`flex-shrink: 0` + `white-space: nowrap` + 合理 `padding`——缺任一项，大量 Tab 时布局必崩
- **展开态禁止 `overflow: visible`**——子元素总高度超过 `max-height` 时会溢出覆盖下方区域，必须用 `overflow-y: auto`
- 展开按钮**在 tab-list 外部**，不会被溢出裁剪，永远可见
- 展开状态下切换 Tab 或其他操作**不自动收起**，只有再次点击才折叠
- 禁止 `overflow-x: auto/scroll`——横向滚动条在 Tab 场景下体验极差
- Tab 内如需附加信息（计数 badge、状态指示灯等），用 `display: flex; align-items: center; gap` 内联排布

---

## 二、卡片布局

### 2.1 瀑布流多列卡片（Masonry）

当页面需要将不定数量、不等高度的卡片紧凑排列时，**必须**使用 JS 手动 Masonry 方案，禁止使用 CSS `columns` 或纯 `flex-wrap`。

**原因**：
- CSS `columns`：每次 DOM 变动会重排所有子元素，导致已有卡片位置跳动/闪烁
- 纯 `flex-wrap`：同行卡片按最高者对齐，短卡片旁会留大片空白

**实现要求**（三要素）：

1. **容器** — 外层 `display: flex; gap; align-items: flex-start`，内含 N 个 `.lane` 纵向列容器（`flex-direction: column`）
2. **列数计算** — `Math.floor(容器宽度 / 单列期望宽度)`，窗口 resize 时按需增列（只增不删，避免重排）
3. **插入策略** — 新卡片始终 `appendChild` 到当前 `scrollHeight` 最小的 lane，已有卡片位置不变

**CSS 骨架**：

```css
.grid { display: flex; gap: 16px; align-items: flex-start; }
.lane { flex: 1; min-width: 300px; max-width: 400px; display: flex; flex-direction: column; gap: 16px; }
.card { /* 单张卡片样式 */ }
```

**JS 骨架**：

```js
function getShortestLane(grid) {
    let min = Infinity, target;
    grid.querySelectorAll('.lane').forEach(l => {
        if (l.scrollHeight < min) { min = l.scrollHeight; target = l; }
    });
    return target;
}
// 新增卡片: getShortestLane(grid).appendChild(card);
```

**禁止事项**：
- 禁止用 `innerHTML` 整体重写 grid（会导致全部卡片闪烁重绘）
- 禁止在流式追加场景中使用 CSS `columns` 属性
