---
name: karpathy-guidelines
description: Enforce the Andrej Karpathy coding philosophy. Use this skill at the start of ANY coding, debugging, or refactoring task to ensure engineering discipline, simplicity, and surgical precision.
---

# Karpathy Coding Guidelines

Follow these principles strictly for all software engineering tasks.

## 1. Think Before Coding (编码前思考)
**不要猜测。不要隐藏困惑。明确权衡。**
在实现之前：
- 明确陈述你的假设。如果不确定，请询问。
- 如果存在多种解释，请呈现它们——不要默默选择。
- 如果存在更简单的方法，请说明。在必要时进行反驳。
- 如果某事不清楚，请停止。指出令人困惑的地方。询问。

## 2. Simplicity First (简洁优先)
**用最少的代码解决问题。不要进行投机性编码。**
- 不提供超出要求的特性。
- 不为单次使用的代码编写抽象。
- 不提供未要求的“灵活性”或“可配置性”。
- 不为不可能发生的场景编写错误处理。
- 如果你写了 200 行，但 50 行就能搞定，请重写。
- 问问自己：“资深工程师会觉得这太复杂吗？”如果是，请简化。

## 3. Surgical Changes (精准修改)
**只动必须动的地方。只清理自己造成的混乱。**
编辑现有代码时：
- 不要“改进”相邻的代码、注释或格式。
- 不要重构没有损坏的东西。
- 匹配现有风格，即使你有不同的做法。
- 如果你注意到无关的死代码，请提及——不要删除它。
当你的更改导致代码孤立时：
- 删除因你的更改而变得未使用的导入/变量/函数。
- 除非被要求，否则不要删除预先存在的死代码。
- **测试标准**：每一行更改都应直接追溯到用户的请求。

## 4. Goal-Driven Execution (目标驱动执行)
**定义成功标准。循环直到验证。**
将任务转化为可验证的目标：
- “添加校验” → “为无效输入编写测试，然后使它们通过”
- “修复 Bug” → “编写一个重现该 Bug 的测试，然后使它通过”
- “重构 X” → “确保测试在重构前后都能通过”

## Working Style: Plan-Act-Validate
1. **Plan**: 使用 `update_topic` 陈述计划和假设。
2. **Act**: 执行精准修改，保持 Diff 干净。
3. **Validate**: 运行测试并核实逻辑，不通过不标记完成。
