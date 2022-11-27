//uses crt;
uses CoreLib;

var
  optimizingStep: integer := 1;
  currentExample: TransportationMatrix;
  
  rateMatrixExample1: array[,] of integer := (
    ( 7, 1, 4,  5,  2),
    (13, 4, 7,  6,  3),
    ( 3, 8, 0, 18, 12),
    ( 9, 5, 3,  4,  7)
  );
  manufacturerVolumesExample1: array of integer := (85, 112, 72, 120);
  customerVolumesExample1: array of integer := (75, 125, 64, 65, 60);
  potentialsRowExample1: array of integer := ArrFill(5, 0);
  potentialsColumnExample1: array of integer := ArrFill(4, 0);
  example1: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample1,
    manufacturerVolumesExample1,
    customerVolumesExample1,
    potentialsRowExample1,
    potentialsColumnExample1
  );
  
  rateMatrixExample2: array[,] of integer := (
    (2, 1, 3, 2),
    (2, 3, 3, 1),
    (3, 3, 2, 1)
  );
  manufacturerVolumesExample2: array of integer := (90, 70, 50);
  customerVolumesExample2: array of integer := (80, 60, 40, 30);
  potentialsRowExample2: array of integer := new integer[4];
  potentialsColumnExample2: array of integer := new integer[3];
  example2: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample2,
    manufacturerVolumesExample2,
    customerVolumesExample2,
    potentialsRowExample2,
    potentialsColumnExample2
  );
  
  rateMatrixExample3: array[,] of integer := (
    (12,  5,  3, 11),
    ( 2, 17, 30,  4),
    (23,  3, 12,  1)
  );
  manufacturerVolumesExample3: array of integer := (55, 93, 27);
  customerVolumesExample3: array of integer := (42, 63, 57, 13);
  potentialsRowExample3: array of integer := new integer[4];
  potentialsColumnExample3: array of integer := new integer[3];
  example3: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample3,
    manufacturerVolumesExample3,
    customerVolumesExample3,
    potentialsRowExample3,
    potentialsColumnExample3
  );

begin
//  Console.OutputEncoding := System.Text.Encoding.GetEncoding(866);
//  TextColor(15); // белый цвет шрифта в консоли
  Writeln('Исходная матрица');
  
  currentExample := example3;
  currentExample.Print();
  
  var minRateIndexes := currentExample.FindMinRateCellIndexes();
  Writeln(
    'Индекс элемента с минимальным тарифом: ',
    $'({minRateIndexes.Item1 + 1} {minRateIndexes.Item2 + 1})'
  );
  
  Writeln('=======================================');
  Writeln('Результат первоначального распределения');
  currentExample.DistributeCargo();
  currentExample.CalculatePotentials();
  var pivotCellIndexes := currentExample.FindPivotCellIndexes();
  
  if (pivotCellIndexes = (-1, -1)) then
  begin
    Writeln('Ответ: ');
    exit;
  end;
  
  currentExample.FindPath(pivotCellIndexes);
  
  currentExample.Print();
end.