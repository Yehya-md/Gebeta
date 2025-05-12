const express = require("express");
const dotenv = require("dotenv");
const mongoose = require("mongoose");
const cors = require("cors");

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI2;

mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log("MongoDB connected");
  })
  .catch((err) => {
    console.error("MongoDB connection error:", err);
  });

// Create a model for the recipe
const recipeSchema = new mongoose.Schema({
  title: { type: String, required: true },
  ingredients: { type: [String], required: true },
  instructions: { type: String, required: true },
  image: { type: String }, // Optional image URL
});

const Recipe = mongoose.model("Recipe", recipeSchema);

app.get("/api/recipes", (req, res) => {
  Recipe.find()
    .then((recipes) => {
      res.json(recipes);
    })
    .catch((err) => {
      console.error("Error fetching recipes:", err);
      res.status(500).json({ error: "Failed to fetch recipes" });
    });
});

// POST: Create a new recipe
app.post("/api/recipes", (req, res) => {
  const { title, ingredients, instructions, image } = req.body;

  const newRecipe = new Recipe({
    title,
    ingredients,
    instructions,
    image,
  });

  newRecipe
    .save()
    .then(() => {
      res.status(201).json({ message: "Recipe created successfully" });
    })
    .catch((err) => {
      console.error("Error saving recipe:", err);
      res.status(500).json({ error: "Failed to create recipe" });
    });
});

// GET: Fetch a single recipe by ID
app.get("/api/recipes/:id", (req, res) => {
  const recipeId = req.params.id;

  Recipe.findById(recipeId)
    .then((recipe) => {
      if (!recipe) {
        return res.status(404).json({ error: "Recipe not found" });
      }
      res.json(recipe);
    })
    .catch((err) => {
      console.error("Error fetching recipe:", err);
      res.status(500).json({ error: "Failed to fetch recipe" });
    });
});

//create a food review schema that recipes comes from user
const foodReviewSchema = new mongoose.Schema({
  title: { type: String, required: true },
  ingredients: { type: [String], required: true },
  instructions: { type: String, required: true },
  image: { type: String }, // Optional image URL
});
const FoodReview = mongoose.model("FoodReview", foodReviewSchema);
// POST: Create a new food review
app.post("/api/food-reviews", (req, res) => {
  const { title, ingredients, instructions, image } = req.body;

  const newFoodReview = new FoodReview({
    title,
    ingredients,
    instructions,
    image,
  });

  newFoodReview
    .save()
    .then(() => {
      res.status(201).json({ message: "Food review created successfully" });
    })
    .catch((err) => {
      console.error("Error saving food review:", err);
      res.status(500).json({ error: "Failed to create food review" });
    });
});
// GET: Fetch all food reviews
app.get("/api/food-reviews", (req, res) => {
  FoodReview.find()
    .then((foodReviews) => {
      res.json(foodReviews);
    })
    .catch((err) => {
      console.error("Error fetching food reviews:", err);
      res.status(500).json({ error: "Failed to fetch food reviews" });
    });
});

//review filter by id
app.get("/api/food-reviews/:id", (req, res) => {
  const reviewId = req.params.id;

  FoodReview.findById(reviewId)
    .then((foodReview) => {
      if (!foodReview) {
        return res.status(404).json({ error: "Food review not found" });
      }
      res.json(foodReview);
    })
    .catch((err) => {
      console.error("Error fetching food review:", err);
      res.status(500).json({ error: "Failed to fetch food review" });
    });
});

//if the review is accepted then it will be added to the recipe
app.post("/api/food-reviews/:id/accept", (req, res) => {
  const reviewId = req.params.id;

  FoodReview.findById(reviewId)
    .then((foodReview) => {
      if (!foodReview) {
        return res.status(404).json({ error: "Food review not found" });
      }

      const newRecipe = new Recipe({
        title: foodReview.title,
        ingredients: foodReview.ingredients,
        instructions: foodReview.instructions,
        image: foodReview.image,
      });

      return newRecipe.save();
    })
    .then(() => {
      res
        .status(201)
        .json({ message: "Food review accepted and added to recipes" });
    })
    .catch((err) => {
      console.error("Error accepting food review:", err);
      res.status(500).json({ error: "Failed to accept food review" });
    });
});

// Test route
app.get("/", (req, res) => {
  res.send("Hello World");
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
