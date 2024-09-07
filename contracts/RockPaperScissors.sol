// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RockPaperScissors {
    enum Move { None, Rock, Paper, Scissors }

    struct Player {
        bytes32 hashedMove; // Player's hashed move
        Move revealedMove;  // The actual move revealed
        uint256 lastAction; // Timestamp of the last action (for 24hr limit)
        bool hasRevealed;   // Whether the player has revealed the move
    }

    address public player1;
    address public player2;
    uint256 public wager;
    bool public gameActive;

    mapping(address => Player) public players;
    
    modifier onlyPlayers() {
        require(msg.sender == player1 || msg.sender == player2, "Not a player");
        _;
    }

    constructor(address _player2) payable {
        player1 = msg.sender;
        player2 = _player2;
        wager = msg.value;
        gameActive = true;
    }

    // Hash move with a secret for submission
    function submitMove(bytes32 _hashedMove) external onlyPlayers {
        require(players[msg.sender].hashedMove == 0, "Move already submitted");
        players[msg.sender] = Player(_hashedMove, Move.None, block.timestamp, false);
    }

    // Reveal the move (hashedMove = keccak256(abi.encodePacked(move, secret)))
    function revealMove(Move _move, string memory _secret) external onlyPlayers {
        require(block.timestamp <= players[getOpponent()].lastAction + 24 hours, "Reveal period expired");
        require(!players[msg.sender].hasRevealed, "Already revealed");

        // Verify the move
        require(keccak256(abi.encodePacked(_move, _secret)) == players[msg.sender].hashedMove, "Invalid reveal");

        players[msg.sender].revealedMove = _move;
        players[msg.sender].hasRevealed = true;
    }

    // Check if both players have revealed their moves
    function determineWinner() external onlyPlayers {
        require(players[player1].hasRevealed && players[player2].hasRevealed, "Both players must reveal");
        
        Move move1 = players[player1].revealedMove;
        Move move2 = players[player2].revealedMove;

        if (move1 == move2) {
            // Draw - refund both players
            payable(player1).transfer(wager);
            payable(player2).transfer(wager);
        } else if ((move1 == Move.Rock && move2 == Move.Scissors) || 
                   (move1 == Move.Paper && move2 == Move.Rock) ||
                   (move1 == Move.Scissors && move2 == Move.Paper)) {
            // Player 1 wins
            payable(player1).transfer(address(this).balance);
        } else {
            // Player 2 wins
            payable(player2).transfer(address(this).balance);
        }
        gameActive = false;
    }

    // Allow the other player to claim the wager if the opponent fails to reveal in time
    function claimTimeoutWin() external onlyPlayers {
        require(!players[getOpponent()].hasRevealed, "Opponent has revealed");
        require(block.timestamp > players[getOpponent()].lastAction + 24 hours, "Time limit not reached");

        payable(msg.sender).transfer(address(this).balance);
        gameActive = false;
    }

    // Helper function to get the opponent's address
    function getOpponent() internal view returns (address) {
        return msg.sender == player1 ? player2 : player1;
    }
}