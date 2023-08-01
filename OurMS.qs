namespace QAOA_TSP{
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    operation Mixer(time:Double, target:Qubit[]):Unit{
        ApplyToEachCA(Rx(-2.0 * time, _), target);
    }

    operation CostLayer()
}