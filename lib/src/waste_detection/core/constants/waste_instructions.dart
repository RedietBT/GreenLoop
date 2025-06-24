class WasteInstructions {
  static const Map<String, Map<String, dynamic>> instructions = {
    'glass': {
      'title': 'Glass Waste',
      'description': 'Glass is 100% recyclable and can be recycled endlessly without loss in quality.',
      'sorting_instructions': [
        'Rinse thoroughly to remove food residue',
        'Remove caps and lids (recycle separately)',
        'Separate by color if possible (clear, green, brown)',
        'Place in designated glass recycling bin',
        'Do not break glass before recycling'
      ],
      'incentives': {
        'points': 15,
        'description': 'Earn 15 points for proper glass recycling',
        'environmental_impact': 'Saves energy equivalent to powering a light bulb for 4 hours'
      },
      'tips': [
        'Glass bottles and jars are always recyclable',
        'Broken glass should be wrapped in paper before disposal',
        'Mirrors and window glass have different recycling processes'
      ]
    },
    'paper': {
      'title': 'Paper Waste',
      'description': 'Paper and cardboard are among the most recyclable materials.',
      'sorting_instructions': [
        'Remove any plastic or metal attachments',
        'Flatten cardboard boxes to save space',
        'Keep paper dry and clean',
        'Separate white paper from colored paper if possible',
        'Place in paper recycling bin'
      ],
      'incentives': {
        'points': 10,
        'description': 'Earn 10 points for proper paper recycling',
        'environmental_impact': 'Saves 17 trees for every ton of paper recycled'
      },
      'tips': [
        'Most paper products are recyclable',
        'Greasy pizza boxes should be composted, not recycled',
        'Shredded paper should be placed in a paper bag before recycling'
      ]
    },
    'metal': {
      'title': 'Metal Waste',
      'description': 'Metals like aluminum and steel are highly valuable recyclable materials.',
      'sorting_instructions': [
        'Rinse containers thoroughly',
        'Crush aluminum cans to save space',
        'Remove any plastic or paper labels if possible',
        'Separate aluminum from steel if possible',
        'Place in metal recycling bin'
      ],
      'incentives': {
        'points': 20,
        'description': 'Earn 20 points for proper metal recycling',
        'environmental_impact': 'Recycling one aluminum can saves enough energy to run a TV for 3 hours'
      },
      'tips': [
        'Aluminum cans are infinitely recyclable',
        'Metal food containers should be clean before recycling',
        'Scrap metal can often be sold for cash'
      ]
    },
    'plastic': {
      'title': 'Plastic Waste',
      'description': 'Plastic recycling helps reduce pollution and conserve resources.',
      'sorting_instructions': [
        'Check the recycling number (1-7) on the bottom',
        'Rinse thoroughly to remove food residue',
        'Remove caps and labels if possible',
        'Crush bottles to save space',
        'Place in plastic recycling bin'
      ],
      'incentives': {
        'points': 12,
        'description': 'Earn 12 points for proper plastic recycling',
        'environmental_impact': 'Recycling one plastic bottle saves enough energy to power a 60W light bulb for 6 hours'
      },
      'tips': [
        'Not all plastics are recyclable - check local guidelines',
        'Plastic bags should be returned to grocery stores',
        'Clean plastic is more valuable for recycling'
      ]
    },
    'organic': {
      'title': 'Organic Waste',
      'description': 'Organic waste can be composted to create nutrient-rich soil.',
      'sorting_instructions': [
        'Separate from other waste types',
        'Remove any plastic or metal contaminants',
        'Cut large items into smaller pieces',
        'Keep moist but not wet',
        'Place in compost bin or organic waste collection'
      ],
      'incentives': {
        'points': 8,
        'description': 'Earn 8 points for proper organic waste composting',
        'environmental_impact': 'Composting reduces methane emissions from landfills'
      },
      'tips': [
        'Fruit and vegetable scraps are excellent for composting',
        'Avoid meat and dairy in home composting',
        'Composting creates natural fertilizer for gardens'
      ]
    },
    'electronic': {
      'title': 'Electronic Waste',
      'description': 'E-waste contains valuable materials and harmful substances that need proper disposal.',
      'sorting_instructions': [
        'Do not throw in regular trash',
        'Remove batteries if possible',
        'Wipe personal data from devices',
        'Find local e-waste collection points',
        'Consider donating working electronics'
      ],
      'incentives': {
        'points': 25,
        'description': 'Earn 25 points for proper e-waste disposal',
        'environmental_impact': 'Prevents toxic materials from entering landfills'
      },
      'tips': [
        'Many electronics stores offer e-waste recycling',
        'Some manufacturers have take-back programs',
        'E-waste contains valuable metals like gold and silver'
      ]
    },
    'unknown': {
      'title': 'No Waste Detected',
      'description': 'Unable to identify the waste type. Only glass, metal, paper, and plastic waste are supported.',
      'sorting_instructions': [
        'Please ensure the image contains recyclable waste',
        'The waste should be clearly visible in the image',
        'Only glass, metal, paper, and plastic waste are supported',
        'Try taking a clearer photo with better lighting',
        'Make sure the waste item is the main focus of the image'
      ],
      'incentives': {
        'points': 0,
        'description': 'No points awarded for unrecognized waste types',
        'environmental_impact': 'Proper identification helps ensure correct recycling'
      },
      'tips': [
        'Supported waste types: glass, metal, paper, plastic',
        'Ensure good lighting and clear focus',
        'Avoid shadows or reflections that might obscure the waste',
        'Try different angles if the first attempt fails'
      ]
    }
  };

  static Map<String, dynamic>? getInstructions(String wasteType) {
    return instructions[wasteType.toLowerCase()] ?? instructions['unknown'];
  }

  static int getPoints(String wasteType) {
    final instruction = getInstructions(wasteType);
    return instruction?['incentives']?['points'] ?? 0;
  }

  static String getTitle(String wasteType) {
    final instruction = getInstructions(wasteType);
    return instruction?['title'] ?? 'Unknown Waste Type';
  }

  static String getDescription(String wasteType) {
    final instruction = getInstructions(wasteType);
    return instruction?['description'] ?? 'Unable to identify the waste type.';
  }

  static List<String> getSortingInstructions(String wasteType) {
    final instruction = getInstructions(wasteType);
    return List<String>.from(instruction?['sorting_instructions'] ?? []);
  }

  static List<String> getTips(String wasteType) {
    final instruction = getInstructions(wasteType);
    return List<String>.from(instruction?['tips'] ?? []);
  }
} 