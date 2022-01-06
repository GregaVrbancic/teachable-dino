<script>
	import { onMount } from "svelte"
	import * as tmImage from '@teachablemachine/image'

	// the link to your model provided by Teachable Machine export panel
	let URL = "https://teachablemachine.withgoogle.com/models/KtB8zRGUb/";
	let errorMessage = ""
	let model, webcam, labelContainer, maxPredictions;
	let jump = false
	let showLoading = false
	let loading = true
	let probability
	let score = 0
	let dino
	let cactus

	onMount(async () => {

	})

	$: {
		if (maxPredictions == 2 && webcam && labelContainer) {
			loading = false

			if (dino && cactus) {
				//console.log(jump, dino, cactus)
				probability = probability
				let dinoRect = dino.getBoundingClientRect()
				let cactusRect = cactus.getBoundingClientRect()

				// collision detection
				if (dinoRect.x < cactusRect.x + cactusRect.width && dinoRect.x + dinoRect.width > cactusRect.x && dinoRect.y < cactusRect.y + cactusRect.height && dinoRect.y + dinoRect.height > cactusRect.y) {
					score -= 10
				} else {
					score += 1
				}
			}
		}
	}

	const loadModel = async() => {
		errorMessage = ""
		showLoading = true
		loading = true
		model = null
		maxPredictions = null
		webcam = null
		labelContainer = null
		score = 0
		document.getElementById("webcam-container").innerHTML = ""
		const modelURL = URL + "model.json";
        const metadataURL = URL + "metadata.json";

        // load the model and metadata
        // Refer to tmImage.loadFromFiles() in the API to support files from a file picker
        // or files from your local hard drive
		// Note: the pose library adds "tmImage" object to your window (window.tmImage)
		try {
			model = await tmImage.load(modelURL, metadataURL);
        	maxPredictions = model.getTotalClasses();
		} catch (error) {
			console.log(error)
			errorMessage = "Ups... Something went wrong. Please check if the given URL is correct."
		}


        // Convenience function to setup a webcam
        const flip = false; // whether to flip the webcam
        webcam = new tmImage.Webcam(200, 200, flip); // width, height, flip
        await webcam.setup(); // request access to the webcam
        await webcam.play();
        window.requestAnimationFrame(loop);

        // append elements to the DOM
        document.getElementById("webcam-container").appendChild(webcam.canvas);
        labelContainer = document.getElementById("label-container");
        for (let i = 0; i < maxPredictions; i++) { // and class labels
            labelContainer.appendChild(document.createElement("div"));
		}
		showLoading = false
	}

	const loop = async() => {
        webcam.update(); // update the webcam frame
        await predict();
        window.requestAnimationFrame(loop);
    }

	// run the webcam image through the image model
    const predict = async() => {
        // predict can take in an image, video or canvas html element
		const prediction = await model.predict(webcam.canvas);

        for (let i = 0; i < maxPredictions; i++) {
            const classPrediction =
                prediction[i].className + ": " + prediction[i].probability.toFixed(2);
            labelContainer.childNodes[i].innerHTML = classPrediction;
		}

		let max = prediction.reduce(function(prev, current) {
			return (prev.probability > current.probability) ? prev : current
		})

		probability = max.probability

		switch (max.className) {
			case "JUMP":
				if (!jump) jump = true
				break;
			default:
				jump = false
				break;
		}
	}
</script>

<main>
	<h1>Teachable Machine - Simple Dino Game</h1>
	<div teachable-model>
		<label for="model-url">Teachable Machine Model URL:</label>
		<input id="model-url" class="url" type=text bind:value="{URL}" />
		<button on:click="{loadModel}">Start</button>
		<p class="error">{errorMessage}</p>
	</div>
	{#if showLoading}
		<div>Loading model, please wait...</div>
	{/if}
	<div class="{loading === true ? 'container hide' : 'container'}">
		<div id="webcam-container"></div>
		<div id="label-container"></div>
		<div class="game">
			<div id="character" bind:this={dino} class="{jump === true ? 'animate' : ''}"></div>
			<div id="cloud"></div>
			<div id="bat"></div>
			<div id="cactus" bind:this={cactus}></div>
		</div>
		<p>Score: <strong>{score}</strong></p>
	</div>
	<div class="footer">
		<span>Made by <a href="https://grega.xyz">Grega Vrbančič</a> with <a href="https://svelte.dev/">Svelte</a> and <a href="https://teachablemachine.withgoogle.com/train/image">Teachable Machine</a>. Source available on <a href="https://github.com/GregaVrbancic/teachable-dino">GitHub</a>.</span>
	</div>
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	h1 {
		color: #ff3e00;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
	}

	.footer {
		position: fixed;
		left: 0;
		bottom: 0;
		width: 100%;
		text-align: center;
		padding-bottom: 1em;
	}

	.url {
		width: 500px;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}

	button:hover {
		cursor: pointer;
	}

	.error {
		color: red;
		font-weight: 400;
	}

	.hide {
		display: none;
	}

	.game {
		width: 600px;
		height: 200px;
		/* border: 1px solid black; */
		margin: 200px auto 0 auto;
		background-image: url("./floor.png");
		background-repeat-y: no-repeat;
    	background-position: bottom;
	}

	#character {
		width: 50px;
		height: 50px;
		background-image: url("./dino.gif");
		position: relative;
		top: 150px;
		z-index: -1;
	}

	.animate {
		animation: jump 0.8s linear;
	}

	@keyframes jump {
		0%{top: 150px;}
		30%{top: 100px;}
		70%{top: 100px;}
		100%{top: 150px;}
	}

	#cloud {
		background-image: url("./cloud.png");
		height: 16px;
		width: 50px;
		position: relative;
		left: 175px;
		top: 20px;
		z-index: -1;
	}

	#bat {
		background-image: url("./bat.png");
		width: 50px;
		height: 38px;
		position: relative;
		top: 0px;
		left: 400px;
		animation: move 3s infinite linear;
	}

	#cactus {
		background-image: url("./cactus.png");
		width: 20px;
		height: 37px;
		position: relative;
		top: 55px;
		left: 600px;
		animation: move 4s infinite linear;
	}

	@keyframes move {
		0%{left: 600px}
		100%{left: -20px}
	}
</style>