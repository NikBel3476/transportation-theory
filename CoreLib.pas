﻿unit CoreLib;

interface

type TransportationMatrix = class
  private
    _cargoToTransitMatrix: array[,] of integer;
    _rateMatrix: array[,] of integer;
    _manufacturerVolumes: array of integer;
    _customerVolumes: array of integer;
  public
    constructor(
      rateMatrix: array[,] of integer;
      manufacturerVolumes: array of integer;
      customerVolumes: array of integer
    );
    begin
      _rateMatrix := rateMatrix;
      _cargoToTransitMatrix := new integer[rateMatrix.GetLength(0), rateMatrix.GetLength(1)];
      _manufacturerVolumes := manufacturerVolumes;
      _customerVolumes := customerVolumes;
    end;
    
    property RateMatrix: array[,] of integer read _rateMatrix;
    property ManufacturerVolumes: array of integer read _manufacturerVolumes;
    property CustomerVolumes: array of integer read _customerVolumes;
    
    procedure Print();
    procedure DistributeCargo();
    function FindMinRateCellIndexes(): (integer, integer);
    function IsDistributeComplete(): boolean;
end;

implementation

procedure TransportationMatrix.Print();
var
  cellWidth: integer := 9;
begin
  // 1st row
  for var i := 0 to self._rateMatrix.GetLength(1) do
    Write('':cellWidth, '|');
  Writeln();
  Write('':cellWidth, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
    Write($'a{i + 1}   ':cellWidth, '|');
  Writeln();
  for var i := 0 to self._rateMatrix.GetLength(1) do
    Write('':cellWidth, '|');
  Writeln();
  
  // matrix
  for var i := 0 to self._rateMatrix.GetLength(1) + 1 do
    Write('——————————':cellWidth + 1);
  Writeln();
  for var i := 0 to self._rateMatrix.GetLength(0) - 1 do
  begin
    // rates row
    Write('':cellWidth, '|');
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      Write(self._rateMatrix[i,j]:cellWidth, '|');
    Writeln();
    // empty row
    for var j := 0 to self._rateMatrix.GetLength(1) do
      Write('':cellWidth, '|');
    Writeln();
    // cargo to transit row
    Write($'A{i + 1}   ':cellWidth, '|');
    for var j := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
      Write($'{self._cargoToTransitMatrix[i,j]}   ':cellWidth, '|');
    // manufacturer volume
    Write($'{self._manufacturerVolumes[i]}   ':cellWidth);
    Writeln();
    // empty row
    for var j := 0 to self._rateMatrix.GetLength(1) do
      Write('':cellWidth, '|');
    Writeln();
    for var j := 0 to self._rateMatrix.GetLength(1) do
      Write('':cellWidth, '|');
    Writeln();
    // divider
    for var j := 0 to self._rateMatrix.GetLength(1) + 1 do
      Write('——————————':cellWidth + 1);
    Writeln();
  end;
  // customer volume
  for var i := 0 to self._rateMatrix.GetLength(1) do
      Write('':cellWidth, '|');
  Writeln();
  Write('':cellWidth, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
    Write($'{self._customerVolumes[i]}   ':cellWidth, '|');
  Writeln();
  for var i := 0 to self._rateMatrix.GetLength(1) do
    Write('':cellWidth, '|');
  Writeln();
end;

procedure TransportationMatrix.DistributeCargo();
var
  currentIndexes: (integer, integer);
  manufacturerVolumes: array of integer := new integer[self._manufacturerVolumes.Length];
  customerVolumes: array of integer := new integer[self._customerVolumes.Length];
begin
  self._manufacturerVolumes.CopyTo(manufacturerVolumes, 0);
  self._customerVolumes.CopyTo(customerVolumes, 0);
  currentIndexes := self.FindMinRateCellIndexes();
  
  while (manufacturerVolumes.Any(v -> v <> 0) and customerVolumes.Any(v -> v <> 0)) do
  begin
    var currentManufacturerVolume := manufacturerVolumes[currentIndexes.Item1];
    var currentCustomerVolume := customerVolumes[currentIndexes.Item2];
    
    if (currentManufacturerVolume > currentCustomerVolume) then
    begin // customer's demand is satisfied
      manufacturerVolumes[currentIndexes.Item1] -= currentCustomerVolume;
      customerVolumes[currentIndexes.Item2] := 0;
      self._cargoToTransitMatrix[currentIndexes.Item1, currentIndexes.Item2] :=
        currentCustomerVolume;
      
      // find new index in row
      var minRate := MaxInt;
      for var i := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
      begin
        if ((i = currentIndexes.Item2) or (customerVolumes[i] = 0)) then
          continue;
        
        var currentRowRate := self._rateMatrix[currentIndexes.Item1, i];
        if (minRate > currentRowRate) then
        begin
          minRate := currentRowRate;
          currentIndexes := (currentIndexes.Item1, i);
        end;
      end;
    end
    else if (currentManufacturerVolume < currentCustomerVolume) then
    begin // the manufacturer's volume is exhausted
      manufacturerVolumes[currentIndexes.Item1] := 0;
      customerVolumes[currentIndexes.Item2] -= currentManufacturerVolume;
      self._cargoToTransitMatrix[currentIndexes.Item1, currentIndexes.Item2] :=
        currentManufacturerVolume;
      
      // find new index in column
      var minRate := MaxInt;
      for var i := 0 to self._cargoToTransitMatrix.GetLength(0) - 1 do
      begin
        if ((i = currentIndexes.Item1) or (manufacturerVolumes[i] = 0)) then
          continue;
        
        var currentColumnRate := self._rateMatrix[i, currentIndexes.Item2];
        if (minRate > currentColumnRate) then
        begin
          minRate := currentColumnRate;
          currentIndexes := (i, currentIndexes.Item2);
        end;
      end;
    end
    else
    begin // the volumes of the manufacturer and the customer are equal
      manufacturerVolumes[currentIndexes.Item1] := 0;
      CustomerVolumes[currentIndexes.Item2] := 0;
      self._cargoToTransitMatrix[currentIndexes.Item1, currentIndexes.Item2] :=
        currentCustomerVolume;
      
      var minRate := MaxInt;
      // find new indexes in whole matrix
      for var i := 0 to self._rateMatrix.GetLength(0) - 1 do
      begin
        if ((i = currentIndexes.Item1) or (manufacturerVolumes[i] = 0)) then
          continue;
        
        for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
        begin
          if ((j = currentIndexes.Item2) or (customerVolumes[j] = 0)) then
            continue;
          
          if (minRate > self._rateMatrix[i,j]) then
          begin
            minRate := self._rateMatrix[i,j];
            currentIndexes := (i, j);
          end;
        end;
      end;
    end;
  end;
end;

function TransportationMatrix.FindMinRateCellIndexes: (integer, integer);
var
  minRate: integer := MaxInt;
begin
  for var i := 0 to self._rateMatrix.GetLength(0) -1  do
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      if (minRate > self._rateMatrix[i,j]) then
      begin
        minRate := self._rateMatrix[i,j];
        Result := (i, j);
      end;
end;

function TransportationMatrix.IsDistributeComplete(): boolean;
var
  rowSum: integer := 0;
  columnSum: integer := 0;
begin
  Result := true;
  // comparison with the manufacturer's volumes
  for var i := 0 to self._cargoToTransitMatrix.GetLength(0) - 1 do
  begin
    rowSum := 0;
    for var j := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
      rowSum += self._cargoToTransitMatrix[i, j];
    
    if (rowSum <> self._manufacturerVolumes[i]) then
    begin
      Result := false;
      break;
    end;
  end;
  
  // comparison with the manufacturer's volumes
  for var i := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
  begin
    columnSum := 0;
    for var j := 0 to self._cargoToTransitMatrix.GetLength(0) - 1 do
      columnSum += self._cargoToTransitMatrix[j, i];
    
    if (columnSum <> self._customerVolumes[i]) then
    begin
      Result := false;
      break;
    end;
  end;
end;

end.