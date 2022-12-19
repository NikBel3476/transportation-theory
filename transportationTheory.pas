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
  
  rateMatrixExample4: array[,] of integer := (
    ( 2, 24,  4,  2,  3),
    (20, 10, 15, 27,  7),
    (15, 15, 12, 25, 19),
    ( 2,  6,  3,  5,  5)
  );
  manufacturerVolumesExample4: array of integer := (28, 13, 15, 30);
  customerVolumesExample4: array of integer := (27, 16, 25, 11, 7);
  potentialsRowExample4: array of integer := new integer[5];
  potentialsColumnExample4: array of integer := new integer[4];
  example4: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample4,
    manufacturerVolumesExample4,
    customerVolumesExample4,
    potentialsRowExample4,
    potentialsColumnExample4
  );
  
  rateMatrixExample5: array[,] of integer := (
    (16, 30, 17, 10,  4),
    (30, 27, 26,  9, 23),
    (13,  4, 22,  3,  1),
    ( 3,  1,  5,  4, 24)
  );
  manufacturerVolumesExample5: array of integer := (4, 6, 10, 10);
  customerVolumesExample5: array of integer := (7, 7, 7, 7, 2);
  potentialsRowExample5: array of integer := new integer[5];
  potentialsColumnExample5: array of integer := new integer[4];
  example5: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample5,
    manufacturerVolumesExample5,
    customerVolumesExample5,
    potentialsRowExample5,
    potentialsColumnExample5
  );
  
  rateMatrixExample6: array[,] of integer := (
    ( 5, 15,  3,  6, 10),
    (23,  8, 13, 27, 12),
    (30,  1,  5, 24, 25),
    ( 8, 26,  7, 28,  9)
  );
  manufacturerVolumesExample6: array of integer := (9, 11, 14, 16);
  customerVolumesExample6: array of integer := (8, 9, 13, 8, 12);
  potentialsRowExample6: array of integer := new integer[5];
  potentialsColumnExample6: array of integer := new integer[4];
  example6: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample6,
    manufacturerVolumesExample6,
    customerVolumesExample6,
    potentialsRowExample6,
    potentialsColumnExample6
  );
  
  rateMatrixExample7: array[,] of integer := (
    (17, 20, 29, 26, 25),
    ( 3,  4,  5, 15, 24),
    (19,  2, 22,  4, 13),
    (20, 27,  1, 17, 19)
  );
  manufacturerVolumesExample7: array of integer := (15, 15, 15, 15);
  customerVolumesExample7: array of integer := (11, 11, 11, 11, 16);
  potentialsRowExample7: array of integer := new integer[5];
  potentialsColumnExample7: array of integer := new integer[4];
  example7: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample7,
    manufacturerVolumesExample7,
    customerVolumesExample7,
    potentialsRowExample7,
    potentialsColumnExample7
  );

begin
//  Console.OutputEncoding := System.Text.Encoding.GetEncoding(866);
//  TextColor(15); // белый цвет шрифта в консоли
  Writeln('Исходная матрица');
  
  currentExample := example7;
  currentExample.Print();
  
  var minRateIndexes := currentExample.FindMinRateCellIndexes();
  Writeln(
    'Индекс элемента с минимальным тарифом: ',
    $'({minRateIndexes.Item1 + 1} {minRateIndexes.Item2 + 1})'
  );
  
  Writeln('==============================================================================');
  currentExample.DistributeCargo();
  currentExample.CalculatePotentials();
  Writeln('Результат первоначального распределения');
  currentExample.Print();
  
  while (true) do
  begin
    var pivotCellIndexes := currentExample.FindPivotCellIndexes();
    if (pivotCellIndexes = (-1, -1)) then
    begin
      Writeln('Ответ: ');
      var totalPrice := currentExample.CalculatePrice();
      Writeln($'f = {totalPrice}');
      exit;
    end;
    
    var path := currentExample.FindPath(pivotCellIndexes);
    Writeln($'Индекс начального элемента контура: ({path[0].Item1 + 1} {path[0].Item2 + 1})');
    
    Writeln('============================================================================');
    if (path.Count > 1) then
      currentExample.Optimize(path);
    currentExample.CalculatePotentials();
    Writeln($'Оптимизация {optimizingStep}');
    currentExample.Print();
    
    optimizingStep += 1;    
  end;
end.