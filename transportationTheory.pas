uses CoreLib;

var
  rateMatrixExample1: array[,] of integer := (
    ( 7, 1, 4,  5,  2),
    (13, 4, 7,  6,  3),
    ( 3, 8, 0, 18, 12),
    ( 9, 5, 3,  4,  7)
  );
  manufacturerVolumesExample1: array of integer := (85, 112, 72, 120);
  customerVolumesExample1: array of integer := (75, 125, 64, 65, 60);
  example1: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample1,
    manufacturerVolumesExample1,
    customerVolumesExample1
  );

begin
  Writeln('Исходная матрица');
  example1.Print();
end.