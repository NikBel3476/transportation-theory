﻿//uses crt;
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
  example1: TransportationMatrix := new TransportationMatrix(
    rateMatrixExample1,
    manufacturerVolumesExample1,
    customerVolumesExample1
  );

begin
//  Console.OutputEncoding := System.Text.Encoding.GetEncoding(866);
//  TextColor(15); // белый цвет шрифта в консоли
  Writeln('Исходная матрица');
  
  currentExample := example1;
  currentExample.Print();
  
  var minRateIndexes := currentExample.FindMinRateCellIndexes();
  Writeln(
    'Индекс элемента с минимальным тарифом: ',
    $'({minRateIndexes.Item1 + 1} {minRateIndexes.Item2 + 1})'
  );
  
  Writeln('=======================================');
  Writeln('Результат первоначального распределения');
  currentExample.DistributeCargo();
  currentExample.Print();
end.