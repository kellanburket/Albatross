//
//  Pattern.swift
//  Passenger
//
//  Created by Kellan Cummings on 6/10/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import Foundation
import Passenger

class Pattern: Passenger {
    
    var commentsCount: Int = 0
    var currency: String?
    var currencySymbol: String?
    var difficultyAverage: Double = 0
    var difficultyCount: Int = 0
    var downloadable: Bool = false
    var favoritesCount: Int = 0
    var free: Bool = false
    var gauge: Int = 0
    var gaugeDescription: String?
    var gaugeDivisor: Int = 0
    var gaugePattern: String?
    var name: String?
    var notes: NSAttributedString?
    var colorFamilyId: Int = 0
    var craft: Craft?
    
    //var download_location
    //var packs
    //

/*

    colorway = "<null>";
    "dye_lot" = "<null>";
    "grams_per_skein" = 100;
    id = 12610;
    "meters_per_skein" = "201.2";
    "ounces_per_skein" = "3.53";
    "personal_name" = "<null>";
    "prefer_metric_length" = 0;
    "prefer_metric_weight" = 1;
    "primary_pack_id" = "<null>";
    "project_id" = "<null>";
    "quantity_description" = "<null>";
    "shop_id" = "<null>";
    "shop_name" = "<null>";
    skeins = "<null>";
    "stash_id" = "<null>";
    "total_grams" = "<null>";
    "total_meters" = "<null>";
    "total_ounces" = "<null>";
    "total_yards" = "<null>";
    "yards_per_skein" = 220;
    yarn =                 {
    id = 523;
    name = "Cascade 220\U00ae";
    permalink = "cascade-yarns-cascade-220";
    "yarn_company_id" = 19;
    "yarn_company_name" = "Cascade Yarns";
};
"yarn_id" = 523;
"yarn_name" = "Cascade Yarns Cascade 220\U00ae";
"yarn_weight" =                 {
        "crochet_gauge" = "<null>";
        id = 12;
        "knit_gauge" = 20;
        "max_gauge" = "<null>";
        "min_gauge" = "<null>";
        name = Worsted;
        ply = 10;
        wpi = 9;
};
}
);
"pattern_attributes" =         (
{
id = 86;
permalink = seamed;
},
{
id = 193;
permalink = icord;
},
{
id = 196;
permalink = felted;
},
{
id = 247;
permalink = "3-dimensional";
},
{
id = 267;
permalink = "written-pattern";
}
);
"pattern_author" =         {
    "favorites_count" = 749;
    id = 242;
    name = "Jordana Paige";
    "patterns_count" = 41;
    permalink = "jordana-paige";
    users =             (
    {
    id = 8112;
    "large_photo_url" = "http://avatars.ravelry.com/JordanaPaige/284364313/ravelry-profile_xlarge.jpg";
    "photo_url" = "http://avatars.ravelry.com/JordanaPaige/284364313/ravelry-profile_large.jpg";
    "small_photo_url" = "http://avatars.ravelry.com/JordanaPaige/284364313/ravelry-profile_small.jpg";
    "tiny_photo_url" = "http://avatars.ravelry.com/JordanaPaige/284364313/ravelry-profile_tiny.jpg";
    username = JordanaPaige;
    }
    );
};
"pattern_categories" =         (
        {
        id = 902;
        name = Other;
        parent =                 {
        id = 516;
        name = Decorative;
        parent =                     {
    id = 449;
    name = Home;
    parent =                         {
            id = 301;
            name = Categories;
            permalink = categories;
    };
    permalink = home;
        };
        permalink = decorative;
        };
        permalink = "other-decorative";
        }
);
"pattern_needle_sizes" =         (
        {
        crochet = 0;
        hook = K;
        id = 11;
        knitting = 1;
        metric = "6.5";
        name = "US 10\U00bd - 6.5 mm";
        "pretty_metric" = "6.5";
        us = "10\U00bd";
        "us_steel" = "<null>";
        }
);
"pattern_type" =         {
            clothing = 0;
            id = 9;
            name = Other;
            permalink = other;
};
"pdf_in_library" = 0;
"pdf_url" = "";
permalink = pumpkins;
"personal_attributes" =         {
                "bookmark_id" = "<null>";
                favorited = 0;
                queued = 0;
};
photos =         (
    {
    "flickr_url" = "http://www.flickr.com/photos/80266574@N00/1183984595";
    id = 324315;
    "medium_url" = "http://farm2.static.flickr.com/1054/1183984595_d2650d4014.jpg";
    "shelved_url" = "<null>";
    "small_url" = "http://farm2.static.flickr.com/1054/1183984595_d2650d4014_m.jpg";
    "sort_order" = 1;
    "square_url" = "http://farm2.static.flickr.com/1054/1183984595_d2650d4014_s.jpg";
    "thumbnail_url" = h;
    "x_offset" = 0;
    "y_offset" = 0;
    }
);
price = "<null>";
printings =         (
        {
        "pattern_source" =                 {
        "amazon_rating" = "<null>";
        "amazon_url" = "<null>";
        author = "";
        id = 625;
        "list_price" = "<null>";
        name = "Knitty, Fall 2005";
        "out_of_print" = 0;
        "patterns_count" = 20;
        permalink = "knitty-fall-2005";
        price = "<null>";
        "shelf_image_path" = "<null>";
        url = "http://knitty.com/ISSUEfall05/index.html";
        };
        "primary_source" = 1;
        }
);
"product_id" = "<null>";
"projects_count" = 335;
published = "2005/09/01";
"queued_projects_count" = 550;
"rating_average" = "3.97435897435897";
"rating_count" = 156;
"ravelry_download" = 0;
"row_gauge" = 20;
"sizes_available" = "";
url = "http://knitty.com/ISSUEfall05/PATTpumpkins.html";
"volumes_in_library" =         (
);
yardage = 440;
"yardage_description" = "440 yards";
"yardage_max" = "<null>";
"yarn_weight" =         {
    "crochet_gauge" = "<null>";
    id = 12;
    "knit_gauge" = 20;
    "max_gauge" = "<null>";
    "min_gauge" = "<null>";
    name = Worsted;
    ply = 10;
    wpi = 9;
};
"yarn_weight_description" = "Worsted / 10 ply (9 wpi)";
*/
}