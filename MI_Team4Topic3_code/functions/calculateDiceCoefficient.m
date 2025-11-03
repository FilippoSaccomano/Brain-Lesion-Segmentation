function diceCoeff = calculateDiceCoefficient(manualMask, autoMask)
    % INPUT:
    % manualMask - Binary mask from manual segmentation
    % autoMask   - Binary mask from automated segmentation
    % OUTPUT:
    % diceCoeff  - Dice Coefficient
   
    % Ensure masks are binary
    manualMask = logical(manualMask);
    autoMask = logical(autoMask);

    diceCoeff=dice(manualMask,autoMask)
end
