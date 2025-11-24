using System;
using Cleaner;

namespace CleanerApp
{
    class Program
    {
        static public void Main(String[] args)
        {
            //Console.WriteLine("Entrez un nom de variable");
            //string entry = Console.ReadLine();

            var cleanThisName = new CleanThisName();
            string res = cleanThisName.CleanNewName(args[1]);
            Console.WriteLine(res);
        }
    }
}
