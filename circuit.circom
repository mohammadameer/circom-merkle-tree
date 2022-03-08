pragma circom 2.0.0;

include "mimcsponge.circom";

template circuit(n) {
    signal input leaves[n]; // leaves of the tree
    signal output root; // merkle root

    var N = n*2-1; // number of nodes

    signal hashes[N]; // hashes of nodes

    component components[N]; // used to help with hashing

    var j = 0; // for non leaves get below nodes hashes

    // for every node
    for (var i = 0; i < N; i++) {
        // if its a leaf
        if (i < n) {
            // hash the leaf value
            components[i] = MiMCSponge(1, 220, 1);
            components[i].k <== i;
            components[i].ins[0] <== leaves[i]; 
        } else {
            // hash node by below nodes hashes
            components[i] = MiMCSponge(2, 220, 1);
            components[i].k <== i;
            components[i].ins[0] <== hashes[j];
            components[i].ins[1] <== hashes[j+1];
            j+=2;
        }
        // save node hash on hashes array
        hashes[i] <== components[i].outs[0];
    }

    // get root hash and constrain
    root <== hashes[N - 1];
}

component main {public [leaves]} = circuit(4);