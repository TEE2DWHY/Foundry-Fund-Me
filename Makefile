-include .env

build:; forge build

deploy-sepolia:
		forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -- --vvvv

deploy-local: 
		forge script script/DeployFundMe.s.sol 
