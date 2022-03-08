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

circom circuit.circom --r1cs --wasm --sym 

cd circuit_js
node generate_witness.js circuit.wasm ../input.json witness.wtns

cp witness.wtns ../witness.wtns
cd ..

snarkjs powersoftau new bn128 16 pot16_0000.ptau -v

snarkjs powersoftau contribute pot16_0000.ptau pot16_0001.ptau --name="First contribution" -v

snarkjs powersoftau prepare phase2 pot16_0001.ptau pot16_final.ptau -v

snarkjs groth16 setup circuit.r1cs pot16_final.ptau circuit_0000.zkey

snarkjs zkey contribute circuit_0000.zkey circuit_0001.zkey --name="1st Contributor Name" -v

snarkjs zkey export verificationkey circuit_0001.zkey verification_key.json

snarkjs groth16 prove circuit_0001.zkey witness.wtns proof.json public.json

snarkjs groth16 verify verification_key.json public.json proof.json

# create solidity file
# snarkjs zkey export solidityverifier circuit_0001.zkey verifier.sol
