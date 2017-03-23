function result = runtests
import matlab.unittest.TestSuite
suiteFolder = TestSuite.fromFolder('tests');

if nargout == 1
  result = run(suiteFolder);
else
  run(suiteFolder);
end