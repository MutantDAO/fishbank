import "./Fishsink.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Depositor {
    using SafeERC20 for IERC20;

    address private fishSink;

    constructor(address _fishSink, address _controller) {
        require(_fishSink != address(0), "Cannnot be the null address");
        fishSink = _fishSink;

        Fishsink(fishSink).register(address(this), _controller);
    }

    function _sinkFish(uint256 _amount) internal {
        IERC20(Fishsink(fishSink).currency()).safeApprove(fishSink, _amount);
        Fishsink(fishSink).deposit(_amount);
    }
}
