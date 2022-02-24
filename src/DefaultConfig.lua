export type Config = {
	baseRate: number?;
	maxBudget: number?;
	initialBudget: number?;
	queueSizeLimit: number?;
}

local defaultConfig: Config = {
	initialBudget = 0;
}

return defaultConfig