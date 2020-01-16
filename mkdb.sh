#!/usr/bin/env runhaskell
import Control.Monad
import Control.Monad.State
import System.Process
import System.Random
import Data.IntMap

-- First install rig:
--  $ apt-get install rig
-- We call `fmap init` to remove trailing '\r'.
getRig s = fmap init . lines <$> readFile ("/usr/share/rig/" <> s <> ".idx")

-- | Make zero-indexed IntMap from list of strings.
zmap = fromList . zip [0..]

main = do
  g <- getStdGen
  females <- getRig "fnames"
  males <- getRig "mnames"
  lastnames <- zmap <$> getRig "lnames"
  let
    firstnames = zmap $ females <> males
    gen = replicateM 100 $ sequence $ pick <$> [firstnames, lastnames, titles, companies]
  db <- mapM addJoke (evalState gen g)
  putStr $ unlines $ show <$> db

addJoke xs = (xs <>) . (:[]) <$>
  readProcess "curl" ["-H", "Accept: text/plain", "https://icanhazdadjoke.com/"] []

pick m = (m!) <$> state (randomR (0, size m - 1))

-- https://online-generator.com/name-generator/company-name-generator.php
companies = zmap
  [ "Trustlane"
  , "mediatech"
  , "Unihex"
  , "Tonottrax"
  , "Konkrunin"
  , "Rankity"
  , "siliconjob"
  , "Opencode"
  , "Latplanet"
  , "zooelectronics"
  , "Quadin"
  , "Xxx--line"
  , "Goldenbase"
  , "Tempcom"
  , "Solgeodox"
  , "plexholdings"
  , "Yearunadax"
  , "Goldcan"
  , "Alphaplus"
  , "Itdox"
  , "Plexsunla"
  , "volplus"
  , "Una-job"
  , "lotbase"
  , "Carecone"
  , "Lineflex"
  , "Unicantax"
  , "Triotechnology"
  , "Lamelectrics"
  ]

-- https://zety.com/blog/job-titles
titles = zmap
  [ "Marketing Specialist"
  , "Marketing Manager"
  , "Marketing Director"
  , "Graphic Designer"
  , "Marketing Research Analyst"
  , "Marketing Communications Manager"
  , "Marketing Consultant"
  , "Product Manager"
  , "Public Relations"
  , "Social Media Assistant"
  , "Brand Manager"
  , "SEO Manager"
  , "Content Marketing Manager"
  , "Copywriter"
  , "Media Buyer"
  , "Digital Marketing Manager"
  , "eCommerce Marketing Specialist"
  , "Brand Strategist"
  , "Vice President of Marketing"
  , "Media Relations Coordinator"
  , "Computer Scientist"
  , "IT Professional"
  , "UX Designer & UI Developer"
  , "SQL Developer"
  , "Web Designer"
  , "Web Developer"
  , "Help Desk Worker/Desktop Support"
  , "Software Engineer"
  , "Data Entry"
  , "DevOps Engineer"
  , "Computer Programmer"
  , "Network Administrator"
  , "Information Security Analyst"
  , "Artificial Intelligence Engineer"
  , "Cloud Architect"
  , "IT Manager"
  , "Technical Specialist"
  , "Application Developer"
  , "Chief Technology Officer (CTO)"
  , "Chief Information Officer (CIO)"
  , "Sales Manager"
  , "Retail Worker"
  , "Store Manager"
  , "Sales Representative"
  , "Sales Manager"
  , "Real Estate Broker"
  , "Sales Associate"
  , "Cashier"
  , "Store Manager"
  , "Account Executive"
  , "Account Manager"
  , "Area Sales Manager"
  , "Direct Salesperson"
  , "Director of Inside Sales"
  , "Outside Sales Manager"
  , "Sales Analyst"
  , "Market Development Manager"
  , "B2B Sales Specialist"
  , "Sales Engineer"
  , "Credit Authorizer"
  , "Benefits Manager"
  , "Credit Counselor"
  , "Accountant"
  , "Bookkeeper"
  , "Accounting Analyst"
  , "Accounting Director"
  , "Accounts Payable/Receivable Clerk"
  , "Auditor"
  , "Budget Analyst"
  , "Controller"
  , "Financial Analyst"
  , "Finance Manager"
  , "Economist"
  , "Payroll Manager"
  , "Payroll Clerk"
  , "Financial Planner"
  , "Financial Services Representative"
  , "Finance Director"
  , "Commercial Loan Officer"
  , "Graphic Designer"
  , "Artist"
  , "Interior Designer"
  , "Video Editor"
  , "Video or Film Producer"
  , "Playwright"
  , "Musician"
  , "Novelist/Writer"
  , "Computer Animator"
  , "Photographer"
  , "Camera Operator"
  , "Sound Engineer"
  , "Motion Picture Director"
  , "Actor"
  , "Music Producer"
  , "Director of Photography"
  ]
