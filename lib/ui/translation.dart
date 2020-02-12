import 'package:jama/data/models/return_visit_model.dart';
import 'package:jama/data/models/visit_model.dart';

class Translation {
  static Map<VisitType, String> visitTypeToString = {
    VisitType.NotAtHome : "Not At Home",
    VisitType.ReturnVisit : "Return Visit",
    VisitType.Study : "Study"
  };

  static Map<PlacementType, String> placementTypeToString = {
    PlacementType.Book: "Book",
    PlacementType.Brochure: "Brochure",
    PlacementType.CampaignItem: "Campaign Item",
    PlacementType.ConventionInvite: "Convention Invite",
    PlacementType.Dvd: "Dvd",
    PlacementType.Invitation: "Invitation",
    PlacementType.Magazine: "Magazine",
    PlacementType.MemorialInvite: "Memorial Invite",
    PlacementType.Tract: "Tract",
    PlacementType.Video: "Video Showing",
    PlacementType.WebLink: "JW.org Link",
    PlacementType.Other: "Other",
  };

  static Map<Gender, String> genderToString = {
    Gender.Male : "Man",
    Gender.Female : "Woman"
  };

  static Map<int, String> daysOfTheWeek = {
    1: "Sunday",
    2: "Monday",
    3: "Tuesday",
    4: "Wednesday",
    5: "Thursday",
    6: "Friday",
    7: "Saturday"
  };
}