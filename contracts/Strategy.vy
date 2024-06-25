# @version 0.3.7

# INTERFACES #

from vyper.interfaces import ERC20
from vyper.interfaces import ERC20Detailed

interface ITokenizedStrategy:
    def initialize(asset: address, name: String[32], management: address, performanceFeeRecipient: address, keeper: address): nonpayable
    def report() -> (uint256, uint256): nonpayable

tokenizedStrategyAddress: public(constant(address)) = 0xBB51273D6c746910C7C06fe718f30c936170feD0

asset: immutable(ERC20)

TokenizedStrategy: immutable(ITokenizedStrategy)

@external
def __init__(_asset: address, name: String[32]):
    asset = ERC20(_asset)
    TokenizedStrategy = ITokenizedStrategy(self)

    sender: bytes32 = convert(msg.sender, bytes32)
    _name: Bytes[96] = _abi_encode(name)

    self._delegate_call(
        concat(
            method_id("initialize(address,String[32],address,address,address)"),
            convert(asset, bytes32),
            _name,
            sender,
            sender,
            sender
        )
    )

@internal
def _deploy_funds(amount: uint256):
    pass

@internal
def _free_funds(amount: uint256):
    pass

@internal
def _harvest_and_report() -> uint256:
    return asset.balanceOf(self)

@internal
def _tend():
    pass

@view
@internal
def _tend_trigger() -> bool:
    return False

@internal
def _emergency_withdraw(amount: uint256):
    pass

@view
@external
def availableDepositLimit(receiver: address) -> uint256:
    return max_value(uint256)

@view
@external
def availableWithdrawLimit(owner: address) -> uint256:
    return max_value(uint256)

@external
def deployFunds(amount: uint256):
    assert msg.sender == self, "!self"
    self._deploy_funds(amount)

@external
def freeFunds(amount: uint256):
    assert msg.sender == self, "!self"
    self._free_funds(amount)

@external
def harvestAndReport() -> uint256:
    assert msg.sender == self, "!self"
    return self._harvest_and_report()

@view
@external
def tendTrigger() -> (bool, Bytes[4]):
    return (
        self._tend_trigger(),
        method_id("tend()")
    )

@external
def tendThis():
    assert msg.sender == self, "!self"
    self._tend()

@external
def shutdownWithdraw(amount: uint256):
    assert msg.sender == self, "!self"
    self._emergency_withdraw(amount)

@internal
def _delegate_call(calldata: Bytes[228]) -> Bytes[64]:

    res: Bytes[64] = raw_call(
        tokenizedStrategyAddress,
        calldata,
        max_outsize=64,
        is_delegate_call=True
    )

    return res

@external
@payable
def __default__():
     # Load the target address from storage
        tokenized_strategy_address: address = tokenizedStrategyAddress
        
        # Perform the delegatecall
        #res: Bytes[64] = self._delegate_call(msg.data)

        raw_call(
            tokenized_strategy_address,  # to
            msg.data,                    # calldata
            max_outsize=0,               # maximum expected return size
            gas=msg.gas,                 # gas limit
            value=0,                     # no ether transfer
            is_delegate_call=True        # delegatecall
        )
        
        success: bool = True

        # Check if the delegatecall was successful
        #if not success:
            #revert()

        # If successful, forward the returned data
        #raw_return()