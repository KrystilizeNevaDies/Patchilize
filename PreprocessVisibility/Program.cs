using System.Runtime.CompilerServices;
using Mono.Cecil;

if (args.Length < 4)
{
    Console.WriteLine("Usage: PreprocessVisibility.exe <inputFolder> <outputFolder> <dependenciesDir> <dllsNamesToInject...>");
    return;
}

var inputFolder = args[0];
var outputFolder = args[1];
var dependenciesDir = args[2];
var dllNamesToInject = args.Skip(3).ToArray();

Console.WriteLine("Starting PreprocessVisibility");

var assembliesToProcess = new List<string>
{
    "Unity.Netcode.Runtime.dll"
};

var resolver = new DefaultAssemblyResolver ();
resolver.AddSearchDirectory(dependenciesDir);
var parameters = new ReaderParameters {
    AssemblyResolver = resolver,
};
var files = Directory.GetFiles(inputFolder);

for (var index = 0; index < files.Length; index++)
{
    Console.Write("Processing {0} of {1} files\r", index + 1, files.Length);
    var input = files[index];
    var fileName = Path.GetFileName(input);
    
    if (!assembliesToProcess.Any(startOfFile => fileName.StartsWith(startOfFile)))
    {
        File.Copy(input, Path.Combine(outputFolder, fileName), true);
        continue;
    }
    
    var asm = ModuleDefinition.ReadModule(input, parameters);
    foreach (var dllNameToInject in dllNamesToInject)
    {
        var constructor = typeof(InternalsVisibleToAttribute).GetConstructor(new[] { typeof(string) });
        var attribute = new CustomAttribute(asm.ImportReference(constructor));
        attribute.ConstructorArguments.Add(new CustomAttributeArgument(asm.TypeSystem.String, dllNameToInject));
        asm.Assembly.CustomAttributes.Add(attribute);
    }
    asm.Write(Path.Combine(outputFolder, fileName));
    Console.WriteLine("Processed {0}", fileName);
}