import { BrowserRouter as Router, Route, Link, Routes } from 'react-router-dom'
import NavBar from 'components/views/NavBar';
import Home from 'components/views/Home';
import 'App.sass';
import Footer from 'components/views/Footer';
import PractisePage from 'components/Exercices/PractisePage';
import { PrivateRoutes } from 'components/PrivateRoutes'
import ExercicesGroup from 'components/Exercices/ExercicesGroup';

// TODO : Make sure there is unity into routing, 
// configuring routing using useNavigate is necessary 
// before delivery
export default function App() {
  let exTitle = 'Practise'
  return (
    <Router>
      <div className='App'>
        <div className='wrapper'>
          <NavBar/>
          <Routes>
            <Route path='/' element={<Home/>}/>
            <Route element={<PrivateRoutes/>}>
              <Route path='/logged' element={<ExercicesGroup/>}/>
              <Route path='/exercice' element={<PractisePage exTitle={exTitle}/>}/>
            </Route>
          </Routes>
          <Footer />
        </div>
      </div>
    </Router>
  );
}
