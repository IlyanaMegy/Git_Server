using System;
using System.Text.RegularExpressions;

namespace Cleaner
{
    public class CleanThisName
    {
        /// <summary>
        /// remplace caractères non anglais (é,è,à,ç,ù,µ...)
        /// </summary>
        /// <param name="entry"> string en entrée qui va être nettoyé</param>
        /// <returns>le nom nettoyé</returns>
        /// 
        public string CleanNewName(string entry)
        {
            //vérifie si l'entrée est nulle
            if (string.IsNullOrEmpty(entry))
            {
                Console.WriteLine("Erreur! Aucune donnée n'a été entrée, nous mettons fin au nettoyage...");
                return entry;
            }

            //vérifie si l'entrée contient un caractère spécial
            if (containsSpecialCharacter(entry))
            {
                //remplace le caratère spécial
                string res = ReplaceThisChar(entry);
                return res;
            }
            return entry;          
        }

        public bool containsSpecialCharacter(string entry)
        {

            Regex rgx = new Regex("[^A-Za-z]");
            bool res = rgx.IsMatch(entry);
            return res;
        }

        public string ReplaceThisChar(string str)
        {
           // Déclaration de variables
            string accent = "ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÌÍÎÏìíîïÙÚÛÜùúûüÿÑñÇç";
            string sansAccent = "AAAAAAaaaaaaOOOOOOooooooEEEEeeeeIIIIiiiiUUUUuuuuyNnCc";

            // Conversion des chaines en tableaux de caractères
            char[] tableauSansAccent = sansAccent.ToCharArray();
            char[] tableauAccent = accent.ToCharArray();

            // Pour chaque accent
            for (int i = 0; i < accent.Length; i++)
            {
                // Remplacement de l'accent par son équivalent sans accent dans la chaîne de caractères
                str = str.Replace(tableauAccent[i].ToString(), tableauSansAccent[i].ToString());
            }

            // Retour du résultat
            return str;
        }
    }
}
