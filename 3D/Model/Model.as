#include "ModelSegment.as"
#include "Interpolation.as"

shared class Model
{
	float scale = 1.0f;

	private float[] matrix;

	private dictionary segments;
	private ModelSegment@ rootSegment;

	Model(float scale)
	{
		this.scale = scale;
	}

	ModelSegment@ AddSegment(string name, string modelPath, string texture)
	{
		return AddSegment(name, ModelSegment(modelPath, texture));
	}

	ModelSegment@ AddSegment(string name, ModelSegment@ segment)
	{
		if (segments.exists(name))
		{
			error("Attempted to add model segment with name that is already in use: " + name);
			printTrace();
			return segment;
		}

		if (segments.isEmpty())
		{
			SetRootSegment(segment);
		}

		segments.set(name, @segment);
		return segment;
	}

	void SetRootSegment(ModelSegment@ segment)
	{
		@rootSegment = segment;
	}

	ModelSegment@ getSegment(string name)
	{
		ModelSegment@ segment;
		segments.get(name, @segment);
		return segment;
	}

	void Render()
	{
		Matrix::MakeIdentity(matrix);

		float[] scaleMatrix;
		Matrix::MakeIdentity(scaleMatrix);
		Matrix::SetScale(scaleMatrix, scale, scale, scale);
		Matrix::MultiplyImmediate(matrix, scaleMatrix);

		rootSegment.Render(matrix, Interpolation::getFrameTime());
	}
}