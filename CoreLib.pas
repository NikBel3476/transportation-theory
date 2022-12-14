unit CoreLib;

interface

type TransportationMatrix = class
  private
    _cargoToTransitMatrix: array[,] of integer;
    _rateMatrix: array[,] of integer;
    _manufacturerVolumes: array of integer;
    _customerVolumes: array of integer;
    _potentialsRow: array of integer;
    _potentialsColumn: array of integer;
    
    function FindPathStep(pivotIndexes: (integer, integer); visited: List<(integer, integer)>): boolean;
  public
    constructor(
      rateMatrix: array[,] of integer;
      manufacturerVolumes: array of integer;
      customerVolumes: array of integer;
      potentialsRow: array of integer;
      potentialsColumn: array of integer
    );
    begin
      _rateMatrix := rateMatrix;
      _cargoToTransitMatrix := new integer[rateMatrix.GetLength(0), rateMatrix.GetLength(1)];
      _manufacturerVolumes := manufacturerVolumes;
      _customerVolumes := customerVolumes;
      _potentialsRow := potentialsRow;
      _potentialsColumn := potentialsColumn;
    end;
    
    property RateMatrix: array[,] of integer read _rateMatrix;
    property ManufacturerVolumes: array of integer read _manufacturerVolumes;
    property CustomerVolumes: array of integer read _customerVolumes;
    
    procedure Print();
    procedure DistributeCargo();
    procedure CalculatePotentials();
    procedure Optimize(path: array of (integer, integer));
    function FindMinRateCellIndexes(): (integer, integer);
    function IsDistributeComplete(): boolean;
    function FindPivotCellIndexes(): (integer, integer);
    function FindPath(pivotIndexes: (integer, integer)): array of (integer, integer);
    function CalculatePrice(): integer;
end;

implementation

procedure TransportationMatrix.Print();
var
  cellWidth: integer := 9;
begin
  // potentials row
  Write('':cellWidth + 6);
  for var i := 0 to self._potentialsRow.Length - 1 do
    Write($'{self._potentialsRow[i]}    ':cellWidth + 1);
  Writeln();
  
  // 1st row
  Write('':cellWidth + 5, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
    Write('':cellWidth, '|');
  Writeln();
  Write('':cellWidth + 5, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
    Write($'a{i + 1}   ':cellWidth, '|');
  Writeln();
  Write('':cellWidth + 5, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
    Write('':cellWidth, '|');
  Writeln();
  
  // divider
  Write('——————————':cellWidth + 6);
  for var i := 0 to self._rateMatrix.GetLength(1) do
    Write('——————————':cellWidth + 1);
  Writeln();
  
  // matrix
  for var i := 0 to self._rateMatrix.GetLength(0) - 1 do
  begin
    // rates row
    Write('':cellWidth + 5, '|');
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      Write(self._rateMatrix[i,j]:cellWidth, '|');
    Writeln();
    // empty row
    Write('':cellWidth + 5, '|');
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      Write('':cellWidth, '|');
    Writeln();
    
    // potential column
    Write($'{self._potentialsColumn[i]}':cellWidth - 4);
    
    // cargo to transit row
    Write($'A{i + 1}   ':cellWidth, '|');
    for var j := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
      Write($'{self._cargoToTransitMatrix[i,j]}   ':cellWidth, '|');
    // manufacturer volume
    Write($'{self._manufacturerVolumes[i]}   ':cellWidth);
    Writeln();
    // empty row
    Write('':cellWidth + 5, '|');
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      Write('':cellWidth, '|');
    Writeln();
    Write('':cellWidth + 5, '|');
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      Write('':cellWidth, '|');
    Writeln();
    // divider
    Write('——————————':cellWidth + 6);
    for var j := 0 to self._rateMatrix.GetLength(1) do
      Write('——————————':cellWidth + 1);
    Writeln();
  end;
  
  // customer volume
  Write('':cellWidth + 5, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
      Write('':cellWidth, '|');
  Writeln();
  Write('':cellWidth + 5, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
    Write($'{self._customerVolumes[i]}   ':cellWidth, '|');
  Writeln();
  Write('':cellWidth + 5, '|');
  for var i := 0 to self._rateMatrix.GetLength(1) - 1 do
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

procedure TransportationMatrix.CalculatePotentials();
var
  isCalculatedRow: array of boolean := ArrFill(self._potentialsRow.Length, false);
  isCalculatedColumn: array of boolean := ArrFill(self._potentialsColumn.Length, false);
begin
  isCalculatedColumn[0] := true;
  self._potentialsColumn[0] := 0;
  
  while (isCalculatedRow.Any(x -> not x) or isCalculatedColumn.Any(x -> not x)) do
  begin
    for var i := 0 to self._rateMatrix.GetLength(0) - 1 do
      for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
      begin
        if (
          (isCalculatedRow[j] and isCalculatedColumn[i])
          or (self._cargoToTransitMatrix[i,j] = 0)
        ) then
          continue;
        
        if (isCalculatedColumn[i] and not isCalculatedRow[j]) then
        begin
          self._potentialsRow[j] := self._rateMatrix[i,j] - self._potentialsColumn[i];
          isCalculatedRow[j] := true;
        end
        else if (isCalculatedRow[j] and not isCalculatedColumn[i]) then
        begin
          self._potentialsColumn[i] := self._rateMatrix[i,j] - self._potentialsRow[j];
          isCalculatedColumn[i] := true;
        end;
      end;
  end;
end;

procedure TransportationMatrix.Optimize(path: array of (integer, integer));
var
  minCargoValue: integer := MaxInt;
begin
  // find min cargo value
  for var i := 0 to path.Length - 1 do
  begin
    var currentCargoValue := self._cargoToTransitMatrix[path[i].Item1, path[i].Item2];
    if ((i mod 2 = 1) and (minCargoValue > currentCargoValue)) then
      minCargoValue := currentCargoValue;
  end;
  
  // optimize
  for var i := 0 to path.Length - 1 do
    if (i mod 2 = 0) then
      self._cargoToTransitMatrix[path[i].Item1, path[i].Item2] += minCargoValue
    else
      self._cargoToTransitMatrix[path[i].Item1, path[i].Item2] -= minCargoValue;
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

function TransportationMatrix.FindPivotCellIndexes(): (integer, integer);
var
  minDifference: integer := MaxInt;
  difference: integer;
begin
  Result := (-1, -1);
  for var i := 0 to self._rateMatrix.GetLength(0) - 1 do
    for var j := 0 to self._rateMatrix.GetLength(1) - 1 do
    begin
      difference := self._rateMatrix[i,j] - self._potentialsRow[j] - self._potentialsColumn[i];
      if ((difference < 0) and (minDifference > difference)) then
      begin
        minDifference := difference;
        Result := (i, j);
      end;
    end;
end;

function TransportationMatrix.FindPath(pivotIndexes: (integer, integer)): array of (integer, integer);
var
  path: List<(integer, integer)> := new List<(integer, integer)>;
  
begin
  path.Add(pivotIndexes);
  self.FindPathStep(pivotIndexes, path);
  
  Result := path.ToArray();
end;

function TransportationMatrix.FindPathStep(
  pivotIndexes: (integer, integer);
  visited: List<(integer, integer)>
): boolean;
var
  nextCells: Queue<(integer, integer)> := new Queue<(integer, integer)>;
begin
  Result := false;
  
  // if element finded
  if (visited.Count > 3) then
  begin
    var originPivotElement := visited.First();
    if (
      (visited.Count mod 2 = 0)
      and ((pivotIndexes.Item1 = originPivotelement.Item1) or (pivotIndexes.Item2 = originPivotElement.Item2))
    ) then
      begin
        Result := true;
        exit;          
      end;
  end;
  
  // find next cells in column
  for var i := 0 to self._cargoToTransitMatrix.GetLength(0) - 1 do
  begin
    if (
      (i = pivotIndexes.Item1)
      or visited.Contains((i, pivotIndexes.Item2))
      or (self._cargoToTransitMatrix[i, pivotIndexes.Item2] = 0)
    ) then
      continue;
    
    nextCells.Enqueue((i, pivotIndexes.Item2));
  end;
  
  // find next cells in row
  for var i := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
  begin
    if (
      (i = pivotIndexes.Item2)
      or visited.Contains((pivotIndexes.Item1, i))
      or (self._cargoToTransitMatrix[pivotIndexes.Item1, i] = 0)
    ) then
      continue;
    
    nextCells.Enqueue((pivotIndexes.Item1, i));
  end;
  
  while (nextCells.Count > 0) do
  begin
    var nextCell := nextCells.Dequeue();
    visited.Add(nextCell);
    Result := self.FindPathStep(nextCell, visited);
    if (Result = true) then
      exit;
    visited.RemoveAt(visited.Count - 1);
  end;
end;

function TransportationMatrix.CalculatePrice(): integer;
begin
  Result := 0;
  for var i := 0 to self._cargoToTransitMatrix.GetLength(0) - 1 do
    for var j := 0 to self._cargoToTransitMatrix.GetLength(1) - 1 do
      Result += self._cargoToTransitMatrix[i, j] * self._rateMatrix[i, j];
end;

end.