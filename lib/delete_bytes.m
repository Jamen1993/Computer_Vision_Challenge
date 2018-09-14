function delete_bytes(nbytes)
    % Delete nbytes written to the terminal by issuing an equal number of backspaces.

    if nbytes == 0
        return;
    end

    fprintf(repmat('\b', 1, sum(nbytes)));
end
