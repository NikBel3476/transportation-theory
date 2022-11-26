unit CoreLib;

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
    function FindMinRateCellIndexes(): (integer, integer);
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

function TransportationMatrix.FindMinRateCellIndexes: (integer, integer);
begin
  
end;

end.