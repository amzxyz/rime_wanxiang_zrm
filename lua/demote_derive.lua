
--万象为了降低1位辅助码权重保证分词，提升2位辅助码权重为了4码高效，但是有些时候单字超越了词组，如自然码中：jmma 睑 剑麻，于是调序 剑麻 睑
local M = {}

function M.func(input, env)
    local context = env.engine.context
    local input_code = context.input -- 获取输入码

    -- 只有当输入码长度等于 4 时才处理
    if utf8.len(input_code) ~= 4 then
        for cand in input:iter() do
            yield(cand) -- 直接按原顺序输出
        end
        return
    end

    local candidates = {} -- 存储前 10 个符合条件的候选词
    local others = {} -- 存储剩余的候选词

    -- 判断是否是数字或字母
    local function is_alnum(text)
        return text:match("^[%w]+$") ~= nil
    end

    -- 读取所有候选词
    local count = 0
    for cand in input:iter() do
        local len = utf8.len(cand.text)
        
        if len == 2 and not is_alnum(cand.text) then
            if count < 10 then
                table.insert(candidates, cand) -- 只存前 10 个符合条件的
            else
                table.insert(others, cand) -- 超过 10 个的，按原顺序放入 others
            end
            count = count + 1
        else
            table.insert(others, cand) -- 不符合长度要求或是字母/数字的，按原顺序存储
        end
    end

    -- 输出前 10 个符合条件的候选词（按原顺序）
    for _, cand in ipairs(candidates) do
        yield(cand)
    end

    -- 其余候选词按原顺序输出
    for _, cand in ipairs(others) do
        yield(cand)
    end
end

return M
