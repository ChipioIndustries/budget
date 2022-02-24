local Llama = require(script.Llama)

local DefaultConfig = require(script.DefaultConfig)

local Budget = {}
Budget.__index = Budget

function Budget.new(config: DefaultConfig.Config?)
	config = Llama.Dictionary.join(DefaultConfig, config or {})

	local self = {
		_budget = config.initialBudget;
		_queue = {};
	}

	setmetatable(self, Budget)

	if config.baseRate then
		task.spawn(function()
			while true do
				task.wait(1 / config.baseRate)
				if (not config.maxBudget) or (self._budget < config.maxBudget)
					self:adjust(1)
				end
			end
		end)
	end

	return self
end

function Budget:_processQueue()
	while self._budget > 0 do
		local nextEntry = self._queue[1]
		table.remove(self._queue, 1)
		nextEntry.approved = true
		self._budget -= 1
	end
end

function Budget:adjust(amount: number)
	local currentBudget = self._budget
	local maxBudget = self.config.maxBudget
	local finalAmount = math.min(currentBudget + amount, maxBudget) - currentBudget
	self._budget += finalAmount
	self:_processQueue()
	return finalAmount
end

function Budget:get()
	return self._budget
end

function Budget:queue()
	local entry = {
		approved = false;
	}

	table.insert(self._queue, entry)

	self:_processQueue()

	while not entry.approved do
		task.wait()
	end
end

return Budget