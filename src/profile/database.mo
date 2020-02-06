import Array "mo:stdlib/array";
import HashMap "mo:stdlib/hashMap";
import Hash "mo:stdlib/hash";
import Iter "mo:stdlib/iter";
import Nat "mo:stdlib/nat";
import Option "mo:stdlib/option";

import Types "./types";

module {
  type NewProfile = Types.NewProfile;
  type Profile = Types.Profile;
  type PrincipalId = Types.PrincipalId;

  public class Directory() {
    // The "database" is just a local hash map
    let hashMap : HashMap.HashMap<PrincipalId, Profile> = init();
    var seeded = false;

    public func createOne(userId : PrincipalId, _profile : NewProfile) {
      ignore hashMap.set(userId, makeProfile(userId, _profile));
    };

    public func updateOne(userId : PrincipalId, profile : Profile) {
      ignore hashMap.set(userId, profile);
    };

    public func findOne(userId : PrincipalId) : ?Profile {
      hashMap.get(userId)
    };

    public func findMany(userIds : [PrincipalId]) : [Profile] {
      func getProfile(userId : PrincipalId) : Profile {
        Option.unwrap<Profile>(hashMap.get(userId))
      };
      Array.map<PrincipalId, Profile>(getProfile, userIds)
    };

    public func findBy(term : Text) : [Profile] {
      var profiles : [Profile] = [];
      for ((id, profile) in hashMap.iter()) {
        let fullName = profile.firstName # " " # profile.lastName;
        if (includesText(fullName, term)) {
          profiles := Array.append<Profile>(profiles, [profile]);
        };
      };
      profiles
    };

    // Helpers

    func makeProfile(userId : PrincipalId, profile : NewProfile) : Profile {
      {
        id = userId;
        firstName = profile.firstName;
        lastName = profile.lastName;
        title = profile.title;
        company = profile.company;
        experience = profile.experience;
        education = profile.education;
        imgUrl = profile.imgUrl;
      }
    };

    func includesText(string : Text, term : Text) : Bool {
      let stringArray = Iter.toArray<Char>(string.chars());
      let termArray = Iter.toArray<Char>(term.chars());

      var i = 0;
      var j = 0;

      while (i < stringArray.len() and j < termArray.len()) {
        if (stringArray[i] == termArray[j]) {
          i += 1;
          j += 1;
          if (j == termArray.len()) { return true; }
        } else {
          i += 1;
          j := 0;
        }
      };
      false
    };

    public func seed() {
      if (seeded) { return; };

      let realPeople : [[Text]] = [
        [
          "Dominic",
          "Williams",
          "Founder & Chief Scientist",
          "DFINITY",
          "**President & Chief Scientist**, DFINITY  \nJan 2015 – Present  \nPalo Alto, CA\n\n**President & CTO**, String Labs, Inc  \nJun 2015 – Feb 2018  \nPalo Alto, CA",
          "**King's College London**  \nBA, Computer Science",
          "https://media-exp1.licdn.com/dms/image/C5603AQHdxGV6zMbg-A/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=Tnsg560fWry_85AVz6MSkeUqOisiSi0e47Hl5T0Yzxk"
        ],
        [
          "Diego",
          "Prats",
          "Director de Producto",
          "DFINITY",
          "**Director of Product**, DFINITY  \nMay 2019 – Present  \nPalo Alto, CA\n\n**VP Product Engineering**, Overnight  \nFeb 2016 – Aug 2018  \nLos Angeles, CA",
          "**Harvard University**  \nBA, Economics",
          "https://media-exp1.licdn.com/dms/image/C5603AQEsCX2F2XWSAA/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=fyvnlBegGsbZSiZcWarxNTBRimRk3vfVTHWb8MH-HLU"
        ],
        [
          "Jan",
          "Camenisch",
          "VP of Research",
          "DFINITY",
          "**VP of Research**, DFINITY  \nSep 2018 – Present  \nZurich, CH\n\n**Principal Research Staff Member**, IBM Research  \nJul 1999 – Aug 2018  \nZurich, CH",
          "**ETH Zurich**  \nPhD, Computer Science / Cryptography",
          "https://media-exp1.licdn.com/dms/image/C5603AQFQTQN-Vnp7Lw/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=_riz0HNQ0NlhTeg3iVcoHjo9oeTM87CrmqTj3ASv518"
        ],
        [
          "Barack",
          "Obama",
          "President(Retired)",
          "United States of America",
          "**President**, USA  \nJan 2009 – Jan 2017  \nWashington, DC",
          "**Harvard University**  \nJD, Law",
          "https://media-exp1.licdn.com/dms/image/C4E03AQF2C6iUecWOnQ/profile-displayphoto-shrink_800_800/0?e=1585180800&v=beta&t=HlFVhKOrVV5QK8AMZb_IDNPSi8oExM9lNIqAoTQ5HKo"
        ],
        [
          "Sanam",
          "Saaber",
          "General Counsel",
          "DFINITY",
          "**General Counsel**, DFINITY  \nMay 2019 – Present  \nPalo Alto, CA\n\n**VP Legal**, Box  \nOct 2012 – May 2019",
          "**University of California, Davis**  \nJD, Law",
          "https://media-exp1.licdn.com/dms/image/C5603AQFLtjzidPnwDQ/profile-displayphoto-shrink_200_200/0?e=1585180800&v=beta&t=bmJEF9yY3J0lcVYlKFs6U57nGCzF69jd6v3P1lHXC1c"
        ]
      ];

      let realProfiles : [Profile] = Array.mapWithIndex<[Text], Profile>(realProfile, realPeople);
      for (profile in realProfiles.vals()) { ignore hashMap.set(profile.id, profile); };

      let mockPeople = [
        ["Flossie","Wilkinson","Musician","Trustlane","Why do bees have sticky hair? Because they use honey combs!"],
        ["Willie","Mejia","Marketing Consultant","mediatech","Have you heard the rumor going around about butter? Never mind, I shouldn't spread it."],
        ["Avis","Garner","Cloud Architect","Latplanet","\"Put the cat out\" \"I didn't realize it was on fire\""],
        ["Edwin","Oliver","IT Professional","Rankity","Where was the Declaration of Independence signed?\n\nAt the bottom! "],
        ["Nichole","Sampson","Computer Scientist","Goldenbase","Two parrots are sitting on a perch. One turns to the other and asks, \"do you smell fish?\""],
        ["Willie","Estes","Accounting Analyst","Lamelectrics","What do you call a fly without wings? A walk."],
        ["Rogelio","Holmes","Vice President of Marketing","Una-job","Why don't seagulls fly over the bay? Because then they'd be bay-gulls!"],
        ["Nora","Pickett","Sales Manager","Unihex","Which side of the chicken has more feathers? The outside."],
        ["Hershel","Sanders","Chief Technology Officer (CTO)","Unihex","When my wife told me to stop impersonating a flamingo, I had to put my foot down."],
        ["Kip","Owens","Marketing Research Analyst","Solgeodox","How does a scientist freshen their breath? With experi-mints!"],
        ["Misty","Singleton","Sales Representative","Quadin","How come the stadium got hot after the game? Because all of the fans left."],
        ["Margarita","Hebert","Cloud Architect","Lamelectrics","I knew i shouldn't have ate that seafood. Because now I'm feeling a little Eel"],
        ["Ashlee","Bond","Sales Associate","volplus","Geology rocks, but Geography is where it's at!"],
        ["Eunice","Drake","Product Manager","Solgeodox","I made a belt out of watches once... It was a waist of time."],
        ["Cynthia","Gentry","Graphic Designer","Tonottrax","What's the difference between a hippo and a zippo? One is really heavy, the other is a little lighter."],
        ["Janette","Lloyd","Vice President of Marketing","Xxx--line","Why was Pavlov's beard so soft?  Because he conditioned it."],
        ["Diana","Carroll","Controller","Tempcom","Why does a Moon-rock taste better than an Earth-rock? Because it's a little meteor."],
        ["Lawanda","Stone","Payroll Clerk","Konkrunin","I've just been reading a book about anti-gravity, it's impossible to put down!"],
        ["Cristina","Chan","Video or Film Producer","Goldenbase","Did you hear about the cow who jumped over the barbed wire fence? It was udder destruction."],
        ["Jefferey","Long","Video Editor","Opencode","I saw an ad in a shop window, \"Television for sale, $1, volume stuck on full\", I thought, \"I can't turn that down\"."],
        ["Kaye","Fleming","Brand Strategist","mediatech","What do you do when you see a space man?\r\nPark your car, man."],
        ["Bryon","Ryan","Content Marketing Manager","Una-job","Every machine in the coin factory broke down all of a sudden without explanation. It just doesn't make any cents."],
        ["Nettie","Glass","Sales Manager","Plexsunla","Did you hear the joke about the wandering nun? She was a roman catholic."],
        ["Delmar","Harrison","Media Relations Coordinator","Carecone","Parallel lines have so much in common. It's a shame they'll never meet."],
        ["Gabrielle","Garrison","Accountant","Tonottrax","Q: What did the spaghetti say to the other spaghetti?\r\nA: Pasta la vista, baby!"],
        ["Raymundo","Gregory","Benefits Manager","Yearunadax","What is the hardest part about sky diving? The ground."],
        ["Amanda","Horn","Accounting Analyst","Plexsunla","In the news a courtroom artist was arrested today, I'm not surprised, he always seemed sketchy."],
        ["Wm","Terrell","Store Manager","Tempcom","Why do pirates not know the alphabet? They always get stuck at \"C\"."],
        ["Louie","Fulton","Sales Engineer","Tempcom","Two dyslexics walk into a bra."],
        ["Mathew","Flores","Sales Engineer","Lamelectrics","What's blue and not very heavy?  Light blue."],
        ["Traci","Bishop","Graphic Designer","Goldenbase","Bad at golf? Join the club."],
        ["Alice","Lambert","Video Editor","Alphaplus","What did Michael Jackson name his denim store?    Billy Jeans!"],
        ["Charley","Zamora","Accounting Director","Latplanet","This morning I was wondering where the sun was, but then it dawned on me."],
        ["Margie","Webb","Accounting Director","Opencode","You can't run through a camp site. You can only ran, because it's past tents."],
        ["Napoleon","Joyner","IT Professional","Una-job","Where do hamburgers go to dance? The meat-ball."],
        ["Nelda","Barr","Controller","Latplanet","Why is the ocean always blue? Because the shore never waves back."],
        ["Guadalupe","Ferrell","Interior Designer","Unicantax","Have you heard the rumor going around about butter? Never mind, I shouldn't spread it."],
        ["Angelique","Irwin","Marketing Research Analyst","Trustlane","Today a man knocked on my door and asked for a small donation towards the local swimming pool. I gave him a glass of water."],
        ["Josue","Baldwin","Application Developer","Goldcan","You will never guess what Elsa did to the balloon. She let it go."],
        ["Lauri","Rosales","Marketing Communications Manager","Trustlane","Did you hear about the scientist who was lab partners with a pot of boiling water? He had a very esteemed colleague."],
        ["Meredith","Doyle","Marketing Manager","Tonottrax","What's the worst thing about ancient history class? The teachers tend to Babylon."],
        ["Susana","Robertson","Finance Director","lotbase","Why did the kid cross the playground? To get to the other slide."],
        ["Marcel","Roman","Financial Analyst","Goldcan","A beekeeper was indicted after he confessed to years of stealing at work. They charged him with emBEEzlement"],
        ["Eula","Frank","Video Editor","mediatech","What did the ocean say to the shore? Nothing, it just waved."],
        ["Connie","Odom","Network Administrator","zooelectronics","A man got hit in the head with a can of Coke, but he was alright because it was a soft drink."],
        ["Everette","Erickson","Auditor","Goldenbase","Why does a Moon-rock taste better than an Earth-rock? Because it's a little meteor."],
        ["Kasey","Oliver","Market Development Manager","Opencode","How do you get two whales in a car? Start in England and drive West."],
        ["Marisol","Herring","Photographer","Trustlane","Did you hear about the cheese factory that exploded in France? There was nothing left but de Brie."],
        ["Lynn","Vasquez","Vice President of Marketing","siliconjob","Never Trust Someone With Graph Paper...\r\n\r\nThey're always plotting something."],
        ["Letitia","Cook","Sales Manager","siliconjob","Why did the belt go to prison? He held up a pair of pants!"],
        ["Mack","Baker","Technical Specialist","Yearunadax","A termite walks into a bar and asks \"Is the bar tender here?\""],
        ["Manuela","May","Sales Associate","Lineflex","I knew a guy who collected candy canes, they were all in mint condition"],
        ["Lucile","Mcguire","Area Sales Manager","volplus","Never Trust Someone With Graph Paper...\r\n\r\nThey're always plotting something."],
        ["Gerald","Arnold","Interior Designer","Quadin","Velcro: What a rip-off."],
        ["Robin","Spears","Information Security Analyst","volplus","I don't play soccer because I enjoy the sport. I'm just doing it for kicks."],
        ["Tia","Madden","Direct Salesperson","Goldcan","\"I'm sorry.\" \"Hi sorry, I'm dad\""],
        ["Vera","Valenzuela","Account Manager","Trustlane","I used to work in a shoe recycling shop. It was sole destroying."],
        ["Marcos","Odom","Marketing Specialist","Unicantax","What did the hat say to the scarf?\r\nYou can hang around. I'll just go on ahead.\r\n"],
        ["Gil","Whitehead","Playwright","Rankity","What do you call someone with no nose? Nobody knows."],
        ["Ronald","Zamora","Marketing Manager","Tempcom","What is the difference between ignorance and apathy?\r\n\r\nI don't know and I don't care."],
        ["Jerri","Alford","Benefits Manager","Lineflex","Today a girl said she recognized me from vegetarian club, but I'm sure I've never met herbivore."],
        ["Jordan","Macdonald","DevOps Engineer","Triotechnology","Two peanuts were walking down the street. One was a salted"],
        ["Nicolas","Cobb","Accountant","Konkrunin","Did you hear that the police have a warrant out on a midget psychic ripping people off? It reads \8220Small medium at large.\8221"],
        ["Lenora","Duffy","Novelist/Writer","Unicantax","What's orange and sounds like a parrot? A Carrot."],
        ["Mamie","Wynn","Store Manager","plexholdings","What does a pirate pay for his corn? A buccaneer!"],
        ["Maritza","Mathews","Product Manager","Latplanet","\"Dad I'm hungry\" \"Hi hungry I'm dad\""],
        ["Kirk","Mercer","Sound Engineer","Konkrunin","They laughed when I said I wanted to be a comedian -- they're not laughing now."],
        ["Connie","Woodward","Novelist/Writer","Triotechnology","Why do mathematicians hate the U.S.? Because it's indivisible."],
        ["Dwayne","Wheeler","Controller","Rankity","This is my step ladder. I never knew my real ladder."],
        ["Vicki","Bryan","Sales Associate","Alphaplus","What did the traffic light say to the car as it passed? \"Don't look I'm changing!\""],
        ["Marcel","Fleming","Financial Analyst","Triotechnology","What kind of dog lives in a particle accelerator? A Fermilabrador Retriever."],
        ["Frances","Ford","Copywriter","Goldcan","Why did the Clydesdale give the pony a glass of water? Because he was a little horse!"],
        ["Darren","Morales","Cashier","Carecone","I ate a clock yesterday. It was so time consuming."],
        ["Ellen","Guthrie","Network Administrator","Triotechnology","Where's the bin? Dad: I haven't been anywhere!"],
        ["Casey","Mcdonald","Information Security Analyst","Konkrunin","I used to be a banker, but I lost interest."],
        ["Alex","Flores","IT Manager","Carecone","Mahatma Gandhi, as you know, walked barefoot most of the time, which produced an impressive set of calluses on his feet. \r\nHe also ate very little, which made him rather frail and with his odd diet, he suffered from bad breath. \r\nThis made him a super calloused fragile mystic hexed by halitosis."],
        ["Janie","Calhoun","Marketing Research Analyst","siliconjob","What did the dog say to the two trees? Bark bark."],
        ["Linwood","Robertson","eCommerce Marketing Specialist","mediatech","Last night me and my girlfriend watched three DVDs back to back. Luckily I was the one facing the TV."],
        ["Olivia","Anderson","Digital Marketing Manager","mediatech","What did the digital clock say to the grandfather clock? Look, no hands!"],
        ["Summer","Sutton","Computer Animator","Opencode","How does a penguin build it's house? Igloos it together."],
        ["Charles","Avery","Area Sales Manager","Yearunadax","I have the heart of a lion... and a lifetime ban from the San Diego Zoo."],
        ["Sarah","Lee","Actor","Tonottrax","Where do sheep go to get their hair cut? The baa-baa shop."],
        ["Reed","Davidson","Web Developer","Lineflex","What do you call a fake noodle? An impasta."],
        ["Dino","Valencia","Artificial Intelligence Engineer","Konkrunin","Why do choirs keep buckets handy? So they can carry their tune"],
        ["Elmo","Merrill","Graphic Designer","Tonottrax","I got fired from a florist, apparently I took too many leaves."],
        ["Leta","Odonnell","Auditor","Triotechnology","I'm reading a book on the history of glue -- can't put it down."],
        ["John","Murray","Graphic Designer","Triotechnology","Archaeology really is a career in ruins."],
        ["Amy","West","IT Professional","siliconjob","What do you call a fashionable lawn statue with an excellent sense of rhythmn? A metro-gnome"],
        ["Johnathon","Lancaster","Payroll Clerk","Lamelectrics","Astronomers got tired watching the moon go around the earth for 24 hours. They decided to call it a day."],
        ["Louis","Diaz","Artist","Unihex","Do I enjoy making courthouse puns? Guilty"],
        ["Willie","Stafford","IT Manager","Carecone","The first time I got a universal remote control I thought to myself, \"This changes everything\""],
        ["Dolly","Lang","Video or Film Producer","Solgeodox","I fear for the calendar, it's days are numbered."],
        ["Clinton","Mccullough","Financial Analyst","Unicantax","Yesterday a clown held a door open for me. I thought it was a nice jester."],
        ["Nora","Blake","Financial Analyst","Una-job","Have you heard about the film \"Constipation\", you probably haven't because it's not out yet."],
        ["Elliott","Burgess","Sound Engineer","Tempcom","Breaking news! Energizer Bunny arrested -- charged with battery."],
        ["Timmy","Colon","Chief Technology Officer (CTO)","Quadin","I was thinking about moving to Moscow but there is no point Russian into things."],
        ["Dona","Mejia","Budget Analyst","Lamelectrics","What do you call a bee that lives in America? A USB."],
        ["Laverne","Tate","Graphic Designer","Yearunadax","Doctor you've got you help me, I'm addicted to twitter. Doctor: I don't follow you."],
        ["Janet","Mays","Vice President of Marketing","Carecone","Why couldn't the lifeguard save the hippie? He was too far out, man."],
        ["Brigitte","Russell","eCommerce Marketing Specialist","Latplanet","Don't tell secrets in corn fields. Too many ears around."]
      ];

      let mockProfiles : [Profile] = Array.mapWithIndex<[Text], Profile>(mockProfile, mockPeople);
      for (profile in mockProfiles.vals()) { ignore hashMap.set(profile.id, profile); };

      seeded := true;
    };

    func realProfile(row : [Text], index : Nat) : Profile {
      {
        id = Nat.toWord32(1000 + index);
        firstName = row[0];
        lastName = row[1];
        title = row[2];
        company = row[3];
        experience = row[4];
        education = row[5];
        imgUrl = row[6];
      }
    };

    func mockProfile(row : [Text], index : Nat) : Profile {
      {
        id = Nat.toWord32(2000 + index);
        firstName = row[0];
        lastName = row[1];
        title = row[2];
        company = row[3];
        experience = row[4];
        education = "";
        imgUrl = "https://i.pravatar.cc/150?u=" # Nat.toText(index);
      }
    };
  };

  func init() : HashMap.HashMap<PrincipalId, Profile> {
    func passthrough(hash : PrincipalId) : PrincipalId { hash };
    HashMap.HashMap<PrincipalId, Profile>(1, Hash.Hash.hashEq, passthrough)
  };
};
