
namespace Quantum.QAOA
{
    //open Microsoft.Quantum.Primitive;

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Convert;

      // This applies the Z-rotation according to the instance Hamiltonian. 
    // We can think of it as Hamiltonian time evolution for time t induced
    // by the Ising Hamiltonian \Sum_ij J_ij Z_i Z_j + \sum_i h_i Z_i.
    operation InstanceHamiltonian(z: Qubit[], t: Double, h: Double[], J: Double[]) : Unit
    {
        using (ancilla = Qubit())
        {
            for (i in 0..5)
            {
                R(PauliZ, 2.0 * t * h[i], z[i]);
            }
            for (i in 0..5)
            {
                for (j in i+1..5)
                {
                    CNOT(z[i], ancilla);
                    CNOT(z[j], ancilla);
                    R(PauliZ, 2.0 * t * J[6*i+j], ancilla);
                    CNOT(z[i], ancilla);
                    CNOT(z[j], ancilla);
                }
            }
        }
    }

    // This applies the X-rotation to each qubit. We can think of it as time evolution
    // induced by applying H = - \Sum_i X_i for time t.
    operation DriverHamiltonian(x: Qubit[], t: Double) : Unit
    {
        for(i in 0..Length(x)-1)
        {
            R(PauliX, -2.0*t, x[i]);
        }
    }

    // Measure all the qubits in the computational basis and reset them to zero.
    operation MeasureAllReset(x: Qubit[]) : Bool[]
    {
        let N = Length(x);
        mutable r = new Bool[N];
        for (i in 0..N-1)
        {
            set r w/= i <- (M(x[i]) == One ? true|false);
        }
        return r;
    }

    // Here is a QAOA algorithm for this Ising Hamiltonian
    operation QAOA_santa(segmentCosts:Double[], penalty:Double, tx: Double[], tz: Double[], p: Int) : Bool[]
    {
        // Calculate Hamiltonian parameters based on the given costs and penalty
        mutable J = new Double[36];
        mutable h = new Double[6];
        for (i in 0..5) {
            set h w/= i <- 4.0 * penalty - 0.5 * segmentCosts[i];
        }
        // Most elements of J_ij equal 2*penalty, so set all elements to this value, then overwrite the exceptions
        for (i in 0..35)
        {
            set J w/= i <- 2.0 * penalty;
        }
        set J w/= 2 <- penalty;
        set J w/= 9 <- penalty;
        set J w/= 29 <- penalty;
        // Now run the QAOA circuit
        mutable r = new Bool[6];
        using (x = Qubit[6])
        {
            ApplyToEach(H, x);                          // prepare the uniform distribution
            for (i in 0..p-1)
            {
                InstanceHamiltonian(x, tz[i], h, J);    // do Exp(-i H_C tz[i])
                DriverHamiltonian(x, tx[i]);            // do Exp(-i H_0 tx[i])
            }
            for i in 0..Length(r){
                set r w/= i <- M(x[i])==One ? true|false;
            }
            //set r = MeasureAllReset(x);                 // measure in the computational basis
        }
        return r;
    }
}
