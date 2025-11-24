<!DOCTYPE html>
<html>
   <head>
      <meta charset="utf-8">
      <title>Entrée</title>

      <!-- fichiers css dans un dossier css -->
      <link rel="stylesheet" href="../css/bootstrap.min.css">
      <link rel="stylesheet" href="../css/style_starter.css">

   </head>

   <body class="container-fluid windows">
      <div class="container content" style="margin-top:3%;">
         <div class="logo"><img src="../logo/logo_lighter.png" alt="BookClub logo" /></div>

         <button class="visiteur_bouton" onclick="window.location.href = 'http://localhost:8080/TP/Bookclub/php/home.php';">Visiteur de passage</button>
         <button class="inscription_bouton" onclick="window.location.href = 'http://localhost:8080/TP/Bookclub/php/inscription.php';">Nouveau membre</button>
         <button class="connexion_bouton" onclick="window.location.href = 'http://localhost:8080/TP/Bookclub/php/connexion.php';">Un connaisseur</button>
      </div>
   </body>
</html>