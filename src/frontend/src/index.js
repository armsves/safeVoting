import { createActor, backend } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";

let actor = backend;
let identity = "2vxsx-fae";

function isAuthenticated(identity) {
  if (identity != "2vxsx-fae") {
    document.getElementById("greeting").innerText = "Welcome " + identity;
    console.log(identity);
    return true;
  }
  return false
}

function toggleVoteElements(authenticated) {
  const dropdown = document.getElementById('dropdown');
  const voteButton = document.getElementById("voteButton");
  //const greeting = document.getElementById("greeting");
  const loginButton = document.getElementById("loginButton");

  dropdown.style.display = authenticated ? 'block' : 'none';
  voteButton.style.display = authenticated ? 'block' : 'none';
  loginButton.style.display = authenticated ? 'block' : 'none';
  //greeting.style.display = authenticated ? 'none' : 'block';
  console.log(authenticated);
  if (authenticated) { loginButton.style.display = "none" };
}

//toggleVoteElements(isAuthenticated());

voteButton.onclick = async (e) => {
  e.preventDefault();
  //voteButton.setAttribute("disabled", true);
  //voteButton.removeAttribute("disabled");
  //console.log(await actor.getAllCandidates());
  //function voteForSelectedCandidate() {
  const dropdown = document.getElementById('dropdown');
  const selectedOption = dropdown.options[dropdown.selectedIndex];
  console.log('selected option ', selectedOption);
  if (selectedOption) {
    //const candidateId = selectedOption.value;
    const candidateId = parseInt(selectedOption.value, 10);;
    console.log('Voted for candidate with ID:', candidateId);
    const responseVote = await actor.vote(candidateId);
    // You can make an API call or perform other actions here
  } else {
    console.warn('No candidate selected');
  }
  //}
  return false;
};

const createButton = document.getElementById("createButton");
createButton.onclick = async (e) => {
  e.preventDefault();
  let nombreCandidato = document.getElementById("nombreCandidato").value;
  console.log(nombreCandidato);
  let respuesta = await actor.createCandidate2(nombreCandidato);
  console.log(respuesta);
  return respuesta;
};


const loginButton = document.getElementById("loginButton");
loginButton.onclick = async (e) => {
  e.preventDefault();

  // create an auth client
  let authClient = await AuthClient.create();

  // start the login process and wait for it to finish
  await new Promise((resolve) => {
    authClient.login({
      identityProvider: process.env.II_URL,
      onSuccess: resolve,
    });
  });

  // At this point we're authenticated, and we can get the identity from the auth client:
  let identity = authClient.getIdentity();
  // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
  const agent = new HttpAgent({ identity });
  // Using the interface description of our webapp, we create an actor that we use to call the service methods.
  actor = createActor(process.env.BACKEND_CANISTER_ID, {
    agent,
  });

  identity = await actor.getCaller();
  //let admin = await actor.getAdmin();
  let isAdmin = await actor.isAdmin();
  
  if (isAdmin) {
    const adminPart = document.getElementById("admin");
    adminPart.style.display = "block"
  };

  if (identity != "2vxsx-fae") {
    // Function to fetch data from the backend and populate the dropdown
    async function fetchDataAndPopulateDropdown() {
      try {
        const response = await actor.getAllCandidates(); // Replace with your actual backend endpoint
        console.log(response);
        //const rawData = await response.text(); // Get the raw response data
        //const data = JSON.parse(response); // Parse the raw data into an array
        console.log(response.length);
        //
        const dropdown = document.getElementById('dropdown');
        dropdown.innerHTML = '';
        const defaultOption = document.createElement('option');
        defaultOption.value = ''; // Set an empty value or another appropriate value
        defaultOption.textContent = 'Select candidate';
        dropdown.appendChild(defaultOption);

        for (let i = response.length - 1; i > -1; i--) {
          const option = response[i];
          const optionElement = document.createElement('option');
          optionElement.value = option.idCandidate; // Use the ID as the value
          optionElement.textContent = option.name; // Use the name as the text
          dropdown.appendChild(optionElement);
        }
        //

        //populateDropdown(response); // Pass the array as options

      } catch (error) {
        console.error('Error fetching data:', error);
      }
    }

    // Call the function to populate the dropdown on page load or wherever you need it
    toggleVoteElements(isAuthenticated(identity));
    fetchDataAndPopulateDropdown();
  }
  return false;
};                