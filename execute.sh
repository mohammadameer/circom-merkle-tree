rm circuit.r1cs
rm circuit.sym
rm circuit_*
rm -r circuit_*
rm pot*
rm proof.json
rm public.json
rm verifier.sol
rm verification_key.json
rm witness.wtns
rm parameters.txt

# compile our circuit and generate
# the r1cs constraints
# the wasm code to generate the witness
# symbols file that can be used for debugging
circom circuit.circom --r1cs --wasm --sym 

# computing the witness
cd circuit_js
node generate_witness.js circuit.wasm ../input.json witness.wtns

cp witness.wtns ../witness.wtns
cd ..

# now we  should creat a trusted setup to generate the proof

# create new power of tau
snarkjs powersoftau new bn128 13 pot13_0000.ptau -v

# contribute to the ceremony
snarkjs powersoftau contribute pot13_0000.ptau pot13_0001.ptau --name="First contribution" -v -e="random text"

# prepare for phase2
snarkjs powersoftau prepare phase2 pot13_0001.ptau pot13_final.ptau -v

# generate zkey file that contain the proof and verfication key
snarkjs groth16 setup circuit.r1cs pot13_final.ptau circuit_0000.zkey

# contribute to phsate2 ceremony
snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v -e="random text"

# export verification key
snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json

# now the witness is computed and trusted setup is ready we generate the proof 
snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json

# now we can verify the proof
snarkjs groth16 verify verification_key.json public.json proof.json

# create solidity file
# snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
